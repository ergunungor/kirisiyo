import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'receipt_parser.dart';

// TODO: Kendi projendeki doğru import yollarını ayarla
// import 'receipt_parser.dart';

/// OCR servis sonucu modeli.
class OcrResult {
  const OcrResult({
    this.merchantName,
    this.totalAmount,
    this.rawText,
    this.confidence = 0.0,
  });

  final String? merchantName;
  final double? totalAmount;
  final String? rawText;
  final double confidence;

  bool get hasValidData => merchantName != null || totalAmount != null;

  @override
  String toString() =>
      'OcrResult(merchant: $merchantName, total: $totalAmount, confidence: $confidence)';
}

abstract interface class IOcrService {
  Future<OcrResult> processImage(Uint8List imageBytes);
  Future<OcrResult> processImageFromUrl(String imageUrl);
}

/// OCR servis implementasyonu (Google Cloud Vision REST API).
class OcrService implements IOcrService {
  const OcrService();

  // TODO: Ekip kanalından Google Cloud Vision API Key'i alıp buraya veya .env dosyasına eklemelisin.
  static const String _apiKey = 'BURAYA_API_KEY_GELECEK';
  static const String _apiUrl =
      'https://vision.googleapis.com/v1/images:annotate?key=$_apiKey';

  @override
  Future<OcrResult> processImage(Uint8List imageBytes) async {
    try {
      // 1. Görseli Base64 formatına çevir (API'nin beklediği format)
      final base64Image = base64Encode(imageBytes);

      // 2. Google Cloud Vision için istek gövdesini hazırla
      final requestBody = {
        'requests': [
          {
            'image': {'content': base64Image},
            'features': [
              {'type': 'DOCUMENT_TEXT_DETECTION'},
            ],
          },
        ],
      };

      // 3. API'ye gönder
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode != 200) {
        debugPrint('OCR API Hatası: ${response.statusCode} - ${response.body}');
        return const OcrResult();
      }

      final responseData = jsonDecode(response.body);
      final responses = responseData['requests'] as List?;

      if (responses == null || responses.isEmpty) {
        return const OcrResult();
      }

      // 4. API'den dönen ham metni al
      final annotations = responses.first['textAnnotations'] as List?;
      if (annotations == null || annotations.isEmpty) {
        return const OcrResult();
      }

      final String rawText = annotations.first['description'] ?? '';

      // 5. Metni daha önce yazdığımız parser ile anlamlı veriye çevir
      final parsedData = ReceiptParser.parse(rawText);

      // 6. Sonucu döndür
      return OcrResult(
        merchantName: parsedData.merchantName,
        totalAmount: parsedData.totalAmount,
        rawText: rawText,
        confidence:
            1.0, // REST üzerinden basit text detection'da genellikle sabit kabul edebiliriz
      );
    } catch (e) {
      debugPrint('OCR İşlem Hatası: $e');
      return const OcrResult();
    }
  }

  @override
  Future<OcrResult> processImageFromUrl(String imageUrl) async {
    // MVP aşamasında cihazdan/kameradan yüklenen dosyaları baz aldığımız için
    // şimdilik bu kısmı boş bırakıyoruz, sadece Web URL'leri desteklemek gerekirse doldurulur.
    throw UnimplementedError('processImageFromUrl henüz implemente edilmedi.');
  }
}

/// Arayüz geliştirmeleri için Sahte (Mock) OCR Servisi
class MockOcrService implements IOcrService {
  const MockOcrService();

  @override
  Future<OcrResult> processImage(Uint8List imageBytes) async {
    // İnternet gecikmesini simüle etmek için 2 saniye bekletiyoruz
    await Future.delayed(const Duration(seconds: 2));

    // Sanki başarılı bir şekilde fiş okunmuş gibi sahte veri dönüyoruz
    return const OcrResult(
      merchantName: 'KAHVE DÜNYASI',
      totalAmount: 145.50,
      rawText: 'KAHVE DÜNYASI\nFİŞ NO: 1234\nTOPLAM 145,50\nKDV DAHİLDİR',
      confidence: 0.95,
    );
  }

  @override
  Future<OcrResult> processImageFromUrl(String imageUrl) async {
    throw UnimplementedError();
  }
}
