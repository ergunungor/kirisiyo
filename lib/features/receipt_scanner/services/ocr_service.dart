import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

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

/// OCR servis arayüzü.
abstract interface class IOcrService {
  Future<OcrResult> processImage(Uint8List imageBytes);
  Future<OcrResult> processImageFromUrl(String imageUrl);
}

/// Gemini destekli OCR servis implementasyonu.
class OcrService implements IOcrService {
  late final GenerativeModel _model;

  OcrService() {
    _model = GenerativeModel(
      model: 'gemini-3.5-flash-lite',
      apiKey: 'YOUR_API_KEY', // Güvenli bir yerden çekmen önerilir
      systemInstruction: Content.system('''
        Sen bir fiş analiz asistanısın. Gönderilen fiş görselinden şu verileri çıkar:
        1. Mağaza Adı (merchant)
        2. Toplam Tutar (total) - sadece sayısal değer (örneğin 125.50)
        
        Çıktıyı SADECE JSON formatında ver: {"merchant": "...", "total": 0.0}
        Başka hiçbir metin veya markdown bloğu ekleme.
      '''),
    );
  }

  @override
  Future<OcrResult> processImage(Uint8List imageBytes) async {
    try {
      Future<Uint8List> _optimizeImage(Uint8List imageBytes) async {
        // Görseli 800px genişliğe çek ve %50 kaliteye düşür.
        // Bu işlem, görsel boyutunu MB'lardan KB'lara düşürür.
        return await FlutterImageCompress.compressWithList(
          imageBytes,
          minWidth: 800,
          minHeight: 800,
          quality: 50,
        );
      }

      final response = await _model.generateContent([
        Content.multi([
          TextPart('Bu fişi analiz et.'),
          DataPart('image/jpeg', imageBytes),
        ]),
      ]);

      final responseText = response.text ?? '';

      // JSON temizleme (Markdown işaretlerini satır bölünmeden tek satırda temizliyoruz)
      final cleanJson =
          responseText.replaceAll('```json', '').replaceAll('```', '').trim();

      final Map<String, dynamic> data = jsonDecode(cleanJson);

      return OcrResult(
        merchantName: data['merchant']?.toString(),
        totalAmount: (data['total'] as num?)?.toDouble(),
        rawText: responseText,
        confidence: 1.0,
      );
    } catch (e) {
      debugPrint('Gemini OCR Hatası: $e');
      return const OcrResult();
    }
  }

  @override
  Future<OcrResult> processImageFromUrl(String imageUrl) async {
    throw UnimplementedError('Bu metot henüz kullanılmıyor.');
  }
}
