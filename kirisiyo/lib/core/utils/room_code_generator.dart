import 'dart:math';

/// 6 haneli benzersiz oda kodu üretici.
///
/// Developer 2 (Room Management) bu yardımcı sınıfı kullanır.
abstract final class RoomCodeGenerator {
  static final Random _random = Random.secure();

  /// 100000-999999 arası 6 haneli sayısal oda kodu üretir.
  static String generate() {
    final code = _random.nextInt(900000) + 100000;
    return code.toString();
  }
}