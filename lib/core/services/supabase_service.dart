import 'package:supabase_flutter/supabase_flutter.dart';

/// Tüm Supabase erişimi bu sınıf üzerinden yapılır.
/// Hiçbir ekran veya widget kendi başına SupabaseClient
/// oluşturmamalıdır — bu, tutarlılık ve güvenlik denetimi
/// için tek merkezi giriş noktasıdır.
class SupabaseService {
  SupabaseService._();

  static SupabaseClient get client => Supabase.instance.client;

  /// Uygulama başlarken bir kez çağrılır (main.dart içinde).
  /// url ve anonKey DIŞARIDAN (--dart-define ile) verilir,
  /// asla bu dosyaya sabit (hardcoded) yazılmaz.
  static Future<void> initialize({
    required String url,
    required String publishableKey,
  }) async {
    if (url.isEmpty || publishableKey.isEmpty) {
      throw Exception(
        'Supabase URL veya publishableKey boş geldi. '
        '--dart-define ile SUPABASE_URL ve SUPABASE_ANON_KEY '
        'değerlerinin verildiğinden emin ol.',
      );
    }

    await Supabase.initialize(
      url: url,
      publishableKey: publishableKey,
    );
  }

  /// Anonymous Auth ile oturum başlatır.
  /// Kullanıcı hiçbir bilgi girmeden arka planda
  /// benzersiz bir kimlik (auth.uid) alır.
  static Future<void> ensureAnonymousSession() async {
    if (client.auth.currentSession == null) {
      await client.auth.signInAnonymously();
    }
  }
}