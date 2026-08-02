import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

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
///
/// TODO [Developer 4]: image_picker ve Supabase Storage entegrasyonunu implement edin.
///
/// Web PWA için notlar:
///   - Kamera erişimi tarayıcı API'sine bağlıdır
///   - `image_picker_for_web` paketi web'de kullanılır
///   - Kullanıcıya izin için browser prompt gösterilecektir
class ImagePickerService implements IImagePickerService {
  ImagePickerService() : _picker = ImagePicker();

  final ImagePicker _picker;

  @override
  Future<Uint8List?> captureFromCamera() async {
    // TODO [Developer 4]: Uygulama adımları:
    //   1. _picker.pickImage(source: ImageSource.camera) çağır
    //   2. Web'de: ImageSource.camera tarayıcı kamerasını açar
    //   3. Null kontrolü yap
    //   4. readAsBytes() ile Uint8List döndür
    //   5. Görüntü kalite optimizasyonu: imageQuality: 85
    throw UnimplementedError(
        'captureFromCamera henüz implementasyonu yapılmadı.');
  }

  @override
  Future<Uint8List?> pickFromGallery() async {
    // TODO [Developer 4]: Uygulama adımları:
    //   1. _picker.pickImage(source: ImageSource.gallery) çağır
    //   2. Null kontrolü yap
    //   3. readAsBytes() ile Uint8List döndür
    //   4. Görüntü boyutu limiti: maxWidth: 1920, maxHeight: 1920
    throw UnimplementedError('pickFromGallery henüz implementasyonu yapılmadı.');
  }

  @override
  Future<String?> uploadToStorage({
    required Uint8List imageBytes,
    required String path,
  }) async {
    // TODO [Developer 4]: Uygulama adımları:
    //   1. SupabaseService.client.storage.from('receipts') kullan
    //   2. .uploadBinary(path, imageBytes) ile yükle
    //   3. .getPublicUrl(path) ile public URL al
    //   4. URL'i döndür
    throw UnimplementedError('uploadToStorage henüz implementasyonu yapılmadı.');
  }
}
