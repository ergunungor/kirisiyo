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
  ///
  /// TODO [Developer 4]: Parse algoritmasını implement edin.
  ///   Önerilen yaklaşım:
  ///   1. Metni satırlara böl
  ///   2. Merchant name için: İlk 3-5 satırı kontrol et,
  ///      genellikle en üstte bulunur
  ///   3. Total amount için:
  ///      - "TOPLAM", "GENEL TOPLAM", "TOTAL", "KDV DAHİL" gibi
  ///        anahtar kelimeleri ara
  ///      - Regex ile para formatını bul: \d{1,6}[,\.]\d{2}
  ///      - En büyük tutarı seç (genellikle toplam olur)
  ///
  /// Türkçe fiş formatları için regex örnekleri:
  ///   - Tutar: r'(\d{1,6}[,\.]\d{2})'
  ///   - Toplam satırı: r'(TOPLAM|GENEL\s+TOPLAM|TOTAL)[\s:]+(.+)'
  static ({String? merchantName, double? totalAmount}) parse(String rawText) {
    // TODO [Developer 4]: Parse implementasyonunu buraya ekleyin.
    return (merchantName: null, totalAmount: null);
  }

  /// Para tutarı string'ini double'a dönüştürür.
  /// Türk formatını destekler: "1.234,56" veya "1234.56"
  ///
  /// TODO [Developer 4]: Format dönüşümünü implement edin.
  static double? parseAmount(String amountText) {
    // TODO [Developer 4]: Uygulama adımları:
    //   1. Nokta ve virgülü normalize et
    //   2. double.tryParse ile dönüştür
    return null;
  }
}
