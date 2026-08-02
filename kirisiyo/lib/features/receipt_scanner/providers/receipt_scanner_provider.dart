import 'package:flutter/foundation.dart';
import '../services/ocr_service.dart';
import '../services/image_picker_service.dart';
import '../services/receipt_parser.dart';

/// Fiş tarayıcı state enum'u.
enum ScannerStatus { idle, picking, uploading, scanning, success, error }

/// Fiş tarama sonucu.
class ScanResult {
  const ScanResult({
    this.merchantName,
    this.totalAmount,
    this.imageUrl,
  });

  final String? merchantName;
  final double? totalAmount;
  final String? imageUrl;

  bool get hasData => merchantName != null || totalAmount != null;
}

/// Fiş tarayıcı provider'ı.
///
/// Developer 4 (AI Receipt Scanner) bu provider'ı yönetir.
///
/// Sorumluluklar:
///   - Kamera/galeri görüntü seçimi
///   - Supabase Storage'a görüntü yükleme
///   - OCR işlemi tetikleme
///   - Tarama sonuçlarını tutma
class ReceiptScannerProvider extends ChangeNotifier {
  ReceiptScannerProvider({
    IOcrService? ocrService,
    IImagePickerService? imagePickerService,
  })  : _ocrService = ocrService ?? const OcrService(),
        _imagePickerService = imagePickerService ?? ImagePickerService();

  final IOcrService _ocrService;
  final IImagePickerService _imagePickerService;

  // ── State ─────────────────────────────────────────────────────────────────

  ScannerStatus _status = ScannerStatus.idle;
  ScannerStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _status != ScannerStatus.idle &&
      _status != ScannerStatus.success &&
      _status != ScannerStatus.error;

  bool get hasError => _status == ScannerStatus.error;

  /// Seçilen görüntünün byte'ları (önizleme için)
  Uint8List? _selectedImageBytes;
  Uint8List? get selectedImageBytes => _selectedImageBytes;

  /// Yüklenen görüntünün URL'i
  String? _uploadedImageUrl;
  String? get uploadedImageUrl => _uploadedImageUrl;

  /// OCR sonucu
  ScanResult? _scanResult;
  ScanResult? get scanResult => _scanResult;

  String? get statusMessage => switch (_status) {
        ScannerStatus.idle => null,
        ScannerStatus.picking => 'Görüntü seçiliyor...',
        ScannerStatus.uploading => 'Görüntü yükleniyor...',
        ScannerStatus.scanning => 'Fiş analiz ediliyor...',
        ScannerStatus.success => 'Analiz tamamlandı!',
        ScannerStatus.error => _errorMessage,
      };

  // ── Aksiyon Metodları ────────────────────────────────────────────────────

  /// Kameradan fotoğraf çeker ve OCR işlemi başlatır.
  ///
  /// TODO [Developer 4]: Tam akışı implement edin:
  ///   captureFromCamera → uploadToStorage → processImage → parse
  Future<void> scanFromCamera({required String roomId}) async {
    _status = ScannerStatus.picking;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO [Developer 4]: Adım 1 — Kameradan görüntü al
      //   _selectedImageBytes = await _imagePickerService.captureFromCamera();
      //   if (_selectedImageBytes == null) { _resetToIdle(); return; }

      // TODO [Developer 4]: Adım 2 — Storage'a yükle
      //   _status = ScannerStatus.uploading; notifyListeners();
      //   final path = 'receipts/$roomId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      //   _uploadedImageUrl = await _imagePickerService.uploadToStorage(
      //     imageBytes: _selectedImageBytes!,
      //     path: path,
      //   );

      // TODO [Developer 4]: Adım 3 — OCR işlemi
      //   _status = ScannerStatus.scanning; notifyListeners();
      //   final ocrResult = await _ocrService.processImage(_selectedImageBytes!);
      //   _scanResult = ScanResult(
      //     merchantName: ocrResult.merchantName,
      //     totalAmount: ocrResult.totalAmount,
      //     imageUrl: _uploadedImageUrl,
      //   );

      _status = ScannerStatus.success;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Galeriden fotoğraf seçer ve OCR işlemi başlatır.
  ///
  /// TODO [Developer 4]: scanFromCamera ile aynı akışı uygulayın,
  ///   sadece ImageSource.gallery kullanın.
  Future<void> scanFromGallery({required String roomId}) async {
    _status = ScannerStatus.picking;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO [Developer 4]: scanFromCamera akışının aynısını uygulayın,
      //   captureFromCamera yerine pickFromGallery kullanın.

      _status = ScannerStatus.success;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// State'i sıfırlar.
  void reset() {
    _status = ScannerStatus.idle;
    _errorMessage = null;
    _selectedImageBytes = null;
    _uploadedImageUrl = null;
    _scanResult = null;
    notifyListeners();
  }

  // ── Private Yardımcı Metodlar ─────────────────────────────────────────────

  void _resetToIdle() {
    _status = ScannerStatus.idle;
    notifyListeners();
  }

  void _setError(String message) {
    _status = ScannerStatus.error;
    _errorMessage = message;
    notifyListeners();
  }
}
