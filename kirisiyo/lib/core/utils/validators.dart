import 'dart:math';
import '../../core/constants/app_constants.dart';

/// Oda kodu üretici yardımcısı.
///
/// TODO [Developer 2]: Üretilen kodun Supabase'de benzersiz olduğunu
/// doğrulamak için repository'de kontrol ekleyin.
abstract final class RoomCodeGenerator {
  static final Random _random = Random.secure();

  static const String _chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  /// [AppConstants.roomCodeLength] uzunluğunda benzersiz oda kodu üretir.
  /// Karıştırılabilecek karakterler (I, O, 0, 1) kasıtlı olarak çıkarılmıştır.
  static String generate() {
    return List.generate(
      AppConstants.roomCodeLength,
      (_) => _chars[_random.nextInt(_chars.length)],
    ).join();
  }
}

/// Validator yardımcıları.
abstract final class Validators {
  /// Boş alan kontrolü.
  static String? required(String? value, [String fieldName = 'Bu alan']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName boş bırakılamaz.';
    }
    return null;
  }

  /// Oda kodu format kontrolü.
  static String? roomCode(String? value) {
    if (value == null || value.isEmpty) return 'Oda kodu boş bırakılamaz.';
    if (value.length != AppConstants.roomCodeLength) {
      return '${AppConstants.roomCodeLength} karakterli oda kodu girin.';
    }
    return null;
  }

  /// Para miktarı kontrolü.
  static String? amount(String? value) {
    if (value == null || value.isEmpty) return 'Miktar boş bırakılamaz.';
    final parsed = double.tryParse(value.replaceAll(',', '.'));
    if (parsed == null) return 'Geçerli bir miktar girin.';
    if (parsed <= 0) return 'Miktar sıfırdan büyük olmalıdır.';
    if (parsed > AppConstants.maxExpenseAmount) {
      return 'Miktar çok yüksek.';
    }
    return null;
  }

  /// Katılımcı adı kontrolü.
  static String? memberName(String? value) {
    if (value == null || value.trim().isEmpty) return 'İsim boş bırakılamaz.';
    if (value.trim().length < 2) return 'İsim en az 2 karakter olmalıdır.';
    return null;
  }
}
