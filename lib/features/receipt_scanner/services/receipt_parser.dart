/// Fiş metin parser'ı.
///
/// Developer 4 (AI Receipt Scanner) bu sınıfı yönetir.
///
/// OCR ham metninden işletme adı ve toplam tutarı çıkarır.
/// Sadece bu iki veriyi döndürür (diğer veriler kapsam dışı).
abstract final class ReceiptParser {
  /// Ham OCR metninden fiş bilgilerini çıkarır.
  ///
  /// Döner: {merchantName: String?, totalAmount: double?}
  static ({String? merchantName, double? totalAmount}) parse(String rawText) {
    if (rawText.trim().isEmpty) {
      return (merchantName: null, totalAmount: null);
    }

    // 1. Metni temiz satırlara böl
    final lines =
        rawText
            .split('\n')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

    if (lines.isEmpty) {
      return (merchantName: null, totalAmount: null);
    }

    // 2. Merchant Name: MVP yaklaşımı - ilk anlamlı satır
    String? merchantName = lines.first;

    // 3. Total Amount: Para formatı regex'i (Örn: 1.234,56 veya 1234.56)
    double? totalAmount;
    final amountRegex = RegExp(
      r'\b(\d{1,3}(?:[.,]\d{3})*[.,]\d{2})\b|\b(\d+[.,]\d{2})\b',
    );

    // Önce "TOPLAM", "GENEL TOPLAM", "TOTAL" kelimelerini içeren satırlara bak
    for (final line in lines) {
      final upperLine = line.toUpperCase();
      if (upperLine.contains('TOPLAM') || upperLine.contains('TOTAL')) {
        final match = amountRegex.firstMatch(line);
        if (match != null) {
          final amount = parseAmount(match.group(0)!);
          if (amount != null) {
            totalAmount = amount;
            break; // İlk eşleşen toplamı bulduk
          }
        }
      }
    }

    // Eğer "TOPLAM" kelimesi OCR tarafından okunamadıysa, fallback (B Planı):
    // Fişteki en büyük para tutarını bul (genellikle fişin en altındaki genel toplamdır).
    if (totalAmount == null) {
      double maxAmount = 0;
      for (final line in lines) {
        final matches = amountRegex.allMatches(line);
        for (final match in matches) {
          final amount = parseAmount(match.group(0)!);
          if (amount != null && amount > maxAmount) {
            maxAmount = amount;
          }
        }
      }
      if (maxAmount > 0) {
        totalAmount = maxAmount;
      }
    }

    return (merchantName: merchantName, totalAmount: totalAmount);
  }

  /// Para tutarı string'ini double'a dönüştürür.
  /// Türk formatını destekler: "1.234,56" veya "1234.56"
  static double? parseAmount(String amountText) {
    // Rakamlar, nokta ve virgül dışındaki her şeyi temizle (₺, $, boşluk vb.)
    String cleanText = amountText.replaceAll(RegExp(r'[^0-9.,]'), '');
    if (cleanText.isEmpty) return null;

    // Eğer hem nokta hem virgül varsa (örn: 1.234,56 veya 1,234.56)
    if (cleanText.contains('.') && cleanText.contains(',')) {
      final lastDot = cleanText.lastIndexOf('.');
      final lastComma = cleanText.lastIndexOf(',');

      if (lastComma > lastDot) {
        // Format: 1.234,56 (Türkçe) - Binlik ayracını sil, virgülü noktaya çevir
        cleanText = cleanText.replaceAll('.', '').replaceAll(',', '.');
      } else {
        // Format: 1,234.56 (İngilizce) - Sadece binlik ayracı olan virgülü sil
        cleanText = cleanText.replaceAll(',', '');
      }
    } else if (cleanText.contains(',')) {
      // Sadece virgül varsa (örn: 1234,56)
      cleanText = cleanText.replaceAll(',', '.');
    }
    // Sadece nokta varsa veya hiçbiri yoksa zaten doğru formatta (örn: 1234.56 veya 1234)

    return double.tryParse(cleanText);
  }
}
