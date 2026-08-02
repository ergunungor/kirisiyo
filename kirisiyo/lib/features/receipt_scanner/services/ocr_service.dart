import 'dart:typed_data';

/// OCR servis sonucu modeli.
class OcrResult {
  const OcrResult({
    this.merchantName,
    this.totalAmount,
    this.rawText,
    this.confidence = 0.0,
  });

  /// Tanınan işletme/mağaza adı
  final String? merchantName;

  /// Tanınan toplam tutar
  final double? totalAmount;

  /// Ham OCR metni (debug için)
  final String? rawText;

  /// OCR güven skoru (0.0 - 1.0)
  final double confidence;

  bool get hasValidData => merchantName != null || totalAmount != null;

  @override
  String toString() =>
      'OcrResult(merchant: $merchantName, total: $totalAmount, confidence: $confidence)';
}

/// OCR servis arayüzü.
///
/// Developer 4 (AI Receipt Scanner) bu arayüzü implemente eder.
abstract interface class IOcrService {
  /// Görüntü byte'larından OCR işlemi yapar.
  /// Sadece [merchantName] ve [totalAmount] döner.
  Future<OcrResult> processImage(Uint8List imageBytes);

  /// Görüntü URL'inden OCR işlemi yapar.
  Future<OcrResult> processImageFromUrl(String imageUrl);
}

/// OCR servis implementasyonu.
///
/// TODO [Developer 4]: OCR backend entegrasyonunu implement edin.
///
/// Önerilen yaklaşımlar:
///   A) Google Cloud Vision API:
///      - Document Text Detection kullanın
///      - receipt_parser.dart ile sonucu parse edin
///
///   B) Supabase Edge Function:
///      - Flutter'dan Supabase Edge Function'a görüntü gönderin
///      - Edge Function içinde Vision API çağrısı yapın
///
///   C) Firebase AI Logic (Gemini):
///      - Multimodal Gemini API kullanın
///      - Structured output ile merchantName ve totalAmount alın
///
/// Referans: Firebase AI Logic skill'ini inceleyin.
class OcrService implements IOcrService {
  const OcrService();

  @override
  Future<OcrResult> processImage(Uint8List imageBytes) async {
    // TODO [Developer 4]: OCR implementasyonunu buraya ekleyin.
    //   Adımlar:
    //   1. imageBytes'ı base64'e dönüştür
    //   2. API'ye gönder (Vision/Gemini/Edge Function)
    //   3. Yanıtı ReceiptParser ile parse et
    //   4. OcrResult döndür
    throw UnimplementedError('processImage henüz implementasyonu yapılmadı.');
  }

  @override
  Future<OcrResult> processImageFromUrl(String imageUrl) async {
    // TODO [Developer 4]: URL'den görüntü indir, processImage çağır
    throw UnimplementedError(
        'processImageFromUrl henüz implementasyonu yapılmadı.');
  }
}
