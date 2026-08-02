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
  // TODO [Developer 5]: Supabase projenizin URL'ini buraya ekleyin.
  static const String _supabaseUrl = 'https://jucclctpanzvbudtkvwq.supabase.co';

  /// Supabase Anon Key'i.
  // TODO [Developer 5]: Supabase projenizin anon key'ini buraya ekleyin.
  static const String _supabaseAnonKey =
      'sb_publishable_buDjT-QBUnM3tQI4xVdjwg_ohdUYucp';

  /// Supabase istemcisini başlatır.
  /// main.dart içinde [initializeApp] çağrılmadan önce çağrılmalıdır.
  static Future<void> initialize() async {
    await Supabase.initialize(
     url: _supabaseUrl,
      anonKey: _supabaseAnonKey,
      // TODO [Developer 5]: Realtime kanalları gerektiğinde burada aktif edin.
    );
  }

  /// Supabase istemcisine erişim noktası.
  static SupabaseClient get client => Supabase.instance.client;
}
