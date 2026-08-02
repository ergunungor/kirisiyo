import 'package:shared_preferences/shared_preferences.dart';

/// Local storage servisi.
///
/// SharedPreferences üzerinde tip-güvenli wrapper sağlar.
/// Developer 1 (Frontend Lead) bu dosyayı yönetir.
class LocalStorageService {
  LocalStorageService._();

  static SharedPreferences? _prefs;

  /// Servisi başlatır. [main.dart] içinde çağrılmalıdır.
  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get _instance {
    assert(_prefs != null, 'LocalStorageService başlatılmamış!');
    return _prefs!;
  }

  // ── Okuma Operasyonları ───────────────────────────────────────────────────

  static String? getString(String key) => _instance.getString(key);

  static bool? getBool(String key) => _instance.getBool(key);

  static int? getInt(String key) => _instance.getInt(key);

  static double? getDouble(String key) => _instance.getDouble(key);

  static List<String>? getStringList(String key) =>
      _instance.getStringList(key);

  // ── Yazma Operasyonları ───────────────────────────────────────────────────

  static Future<bool> setString(String key, String value) =>
      _instance.setString(key, value);

  static Future<bool> setBool(String key, bool value) =>
      _instance.setBool(key, value);

  static Future<bool> setInt(String key, int value) =>
      _instance.setInt(key, value);

  static Future<bool> setDouble(String key, double value) =>
      _instance.setDouble(key, value);

  static Future<bool> setStringList(String key, List<String> value) =>
      _instance.setStringList(key, value);

  // ── Silme Operasyonları ───────────────────────────────────────────────────

  static Future<bool> remove(String key) => _instance.remove(key);

  static Future<bool> clear() => _instance.clear();

  static bool containsKey(String key) => _instance.containsKey(key);
}
