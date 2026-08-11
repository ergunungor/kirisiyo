import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase istemci servisi.
///
/// Tüm Supabase erişimleri bu servis üzerinden yapılır.
/// Developer 5 (Backend) bu dosyayı yönetir.
///
/// Kullanım:
/// ```dart
/// final client = SupabaseService.client;
/// ```
class SupabaseService {
  SupabaseService._();

  /// Supabase URL'i — environment variable veya flutter_dotenv ile yönetin.
  static const String _supabaseUrl = 'https://jucclctpanzvbudtkvwq.supabase.co';

  /// Supabase Anon Key'i.
  static const String _supabaseAnonKey =
      'sb_publishable_buDjT-QBUnM3tQI4xVdjwg_ohdUYucp';

  /// Supabase istemcisini başlatır.
  static Future<void> initialize() async {
    await Supabase.initialize(url: _supabaseUrl, anonKey: _supabaseAnonKey);

    final client = Supabase.instance.client;

    try {
      if (client.auth.currentUser == null) {
        await client.auth.signInAnonymously();
      }

      debugPrint('Current user: ${client.auth.currentUser?.id}');
    } catch (e) {
      debugPrint('Anonymous sign in failed: $e');
    }
  }

  /// Supabase istemcisine erişim noktası.
  static SupabaseClient get client => Supabase.instance.client;
}
