import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
// TODO [Developer 4]: Kendi projendeki SupabaseService (veya benzeri) importunu buraya eklemelisin.
// import '../../../core/services/supabase_service.dart';

/// Görüntü seçici servis arayüzü.
///
/// Developer 4 (AI Receipt Scanner) bu servisi yönetir.
abstract interface class IImagePickerService {
  /// Kameradan fotoğraf çeker.
  Future<Uint8List?> captureFromCamera();

  /// Galeriden fotoğraf seçer.
  Future<Uint8List?> pickFromGallery();

  /// Supabase Storage'a görüntü yükler.
  /// Döner: Public URL veya null (hata durumunda)
  Future<String?> uploadToStorage({
    required Uint8List imageBytes,
    required String path,
  });
}

/// Görüntü seçici servis implementasyonu.
class ImagePickerService implements IImagePickerService {
  ImagePickerService() : _picker = ImagePicker();

  final ImagePicker _picker;

  @override
  Future<Uint8List?> captureFromCamera() async {
    try {
      // Web PWA'da ImageSource.camera tarayıcının kamera iznini ve arayüzünü tetikler.
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85, // Hızlı yükleme ve OCR için boyutu optimize ediyoruz
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (image == null) return null;

      // Web ortamında File çalışmaz, doğrudan byte olarak okuyoruz
      return await image.readAsBytes();
    } catch (e) {
      debugPrint('Kamera hatası: $e');
      return null;
    }
  }

  @override
  Future<Uint8List?> pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (image == null) return null;
      return await image.readAsBytes();
    } catch (e) {
      debugPrint('Galeri hatası: $e');
      return null;
    }
  }

  @override
  Future<String?> uploadToStorage({
    required Uint8List imageBytes,
    required String path,
  }) async {
    try {
      // TODO [Developer 4]: SupabaseService.client yapısının projende var olduğunu varsayarak ilerliyorum.
      // Kendi yapına göre import edip aşağıdaki yorum satırlarını aktif et.

      /*
      await SupabaseService.client.storage
          .from('receipts')
          .uploadBinary(
            path, 
            imageBytes,
          );

      final publicUrl = SupabaseService.client.storage
          .from('receipts')
          .getPublicUrl(path);

      return publicUrl;
      */

      throw UnimplementedError(
        'Supabase entegrasyonu import edildikten sonra üstteki kodu açın.',
      );
    } catch (e) {
      debugPrint('Storage yükleme hatası: $e');
      return null;
    }
  }
}
