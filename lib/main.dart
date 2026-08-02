import 'package:flutter/material.dart';
import 'app/app.dart';
import 'core/services/supabase_service.dart';
import 'core/services/local_storage_service.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Kırışıyo — Uygulama giriş noktası.
///
/// Developer 1 (Frontend Lead) bu dosyayı yönetir.
///
/// Başlatma sırası:
///   1. Flutter binding
///   2. Local storage
///   3. Supabase
///   4. App çalıştır
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('tr_TR', null);

  // ── Servis Başlatma ───────────────────────────────────────────────────────
  await LocalStorageService.initialize();

  // TODO [Developer 5]: Supabase URL ve Anon Key'i ayarladıktan sonra
  //   aşağıdaki satırı uncomment edin.
  await SupabaseService.initialize();

  runApp(const KirisiyoApp());
}
