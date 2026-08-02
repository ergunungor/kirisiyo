import 'dart:math';

abstract final class RoomCodeGenerator {
  static final Random _random = Random.secure();

  // I, O, 0 ve 1 bilinçli olarak çıkarıldı.
  static const String _chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  /// 8 karakterlik oda kodu üretir.
  static String generate() {
    return List.generate(
      8,
      (_) => _chars[_random.nextInt(_chars.length)],
    ).join();
  }
}
