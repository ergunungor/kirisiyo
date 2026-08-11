/// Kırışıyo uygulama sabitleri.
///
/// Developer 1 (Frontend Lead) bu dosyayı yönetir.
abstract final class AppConstants {
  // ── Uygulama Bilgileri ────────────────────────────────────────────────────
  static const String appName = 'Kırışıyo';
  static const String appVersion = '1.0.0';
  static const String appTagline =
      'Harcamalarını arkadaşlarınla kolayca paylaş';

  // ── Oda Ayarları ─────────────────────────────────────────────────────────
  /// Oda kodunun uzunluğu
  static const int roomCodeLength = 8;

  /// Bir odada izin verilen maksimum katılımcı sayısı
  static const int maxParticipants = 20;

  /// Oda adı maksimum karakter sayısı
  static const int roomNameMaxLength = 50;

  // ── Harcama Ayarları ─────────────────────────────────────────────────────
  /// Harcama başlığı maksimum karakter sayısı
  static const int expenseTitleMaxLength = 100;

  /// Maksimum harcama miktarı (TL)
  static const double maxExpenseAmount = 1000000.0;

  /// Para birimi sembolü
  static const String currencySymbol = '₺';

  /// Para birimi kodu
  static const String currencyCode = 'TRY';

  // ── Paylaşım Ayarları ────────────────────────────────────────────────────
  /// Derin link base URL'i (Firebase Hosting üzerinde)

  static const String deepLinkBaseUrl = 'https://kirisiyoapp.web.app';

  /// Oda davet link şablonu
  static String roomInviteLink(String roomCode) =>
      '$deepLinkBaseUrl/room/$roomCode';

  // ── Cache Süreleri ────────────────────────────────────────────────────────
  static const Duration cacheExpiry = Duration(minutes: 5);

  // ── Animasyon Süreleri ────────────────────────────────────────────────────
  static const Duration splashDuration = Duration(milliseconds: 2500);
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 400);
  static const Duration animationSlow = Duration(milliseconds: 600);

  // ── Supabase Tablo Adları ─────────────────────────────────────────────────
  static const String tableRooms = 'rooms';
  static const String tableRoomMembers = 'room_members';
  static const String tableExpenses = 'expenses';
  static const String tableExpenseSplits = 'expense_splits';

  // ── SharedPreferences Key'leri ───────────────────────────────────────────
  static const String prefCurrentRoomCode = 'current_room_code';
  static const String prefCurrentMemberId = 'current_member_id';

  // ── Hata Mesajları ────────────────────────────────────────────────────────
  static const String errorGeneric = 'Bir hata oluştu. Lütfen tekrar deneyin.';
  static const String errorNetwork =
      'Bağlantı hatası. İnternet bağlantınızı kontrol edin.';
  static const String errorRoomNotFound =
      'Oda bulunamadı. Oda kodunu kontrol edin.';
  static const String errorRoomFull =
      'Bu oda dolu. Maksimum katılımcı sayısına ulaşıldı.';
}
