import 'package:flutter/material.dart';

/// Kırışıyo renk paleti.
///
/// Tüm renk sabitleri burada tanımlanır.
/// Renk değerlerini değiştirmek için yalnızca bu dosyayı düzenleyin.
///
/// Developer 1 (Frontend Lead) bu dosyayı yönetir.
abstract final class AppColors {
  // ── Ana Renkler ──────────────────────────────────────────────────────────

  /// Birincil marka rengi — derin mor/indigo
  static const Color primary = Color(0xFF6C63FF);

  /// Birincil rengin açık tonu
  static const Color primaryLight = Color(0xFF9C94FF);

  /// Birincil rengin koyu tonu
  static const Color primaryDark = Color(0xFF3D35CC);

  /// İkincil vurgu rengi — canlı turkuaz
  static const Color secondary = Color(0xFF00D4AA);

  /// İkincil rengin açık tonu
  static const Color secondaryLight = Color(0xFF5DFFDA);

  // ── Arka Plan Renkleri ───────────────────────────────────────────────────

  /// Ana arka plan (dark theme)
  static const Color backgroundDark = Color(0xFF0F0E1A);

  /// Kart arka planı
  static const Color surface = Color(0xFF1C1B2E);

  /// Yükseltilmiş kart arka planı
  static const Color surfaceElevated = Color(0xFF252438);

  /// Bölücü rengi
  static const Color divider = Color(0xFF2E2D42);

  // ── Metin Renkleri ───────────────────────────────────────────────────────

  /// Ana metin rengi
  static const Color textPrimary = Color(0xFFF0EEFF);

  /// İkincil metin rengi
  static const Color textSecondary = Color(0xFF9B99B8);

  /// Devre dışı metin rengi
  static const Color textDisabled = Color(0xFF4A4862);

  // ── Anlam Renkleri ───────────────────────────────────────────────────────

  /// Borç rengi (kırmızı)
  static const Color debtRed = Color(0xFFFF5A7E);

  /// Alacak rengi (yeşil)
  static const Color creditGreen = Color(0xFF2ECC71);

  /// Uyarı rengi (sarı)
  static const Color warning = Color(0xFFFFC107);

  /// Bilgi rengi (mavi)
  static const Color info = Color(0xFF4FC3F7);

  // ── Gradient Tanımları ───────────────────────────────────────────────────

  /// Birincil gradient (butonlar, kartlar)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF9C63FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Arka plan gradient
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [backgroundDark, Color(0xFF1A1830)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Alacak gradient (yeşil tonu)
  static const LinearGradient creditGradient = LinearGradient(
    colors: [Color(0xFF2ECC71), Color(0xFF1ABC9C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Borç gradient (kırmızı tonu)
  static const LinearGradient debtGradient = LinearGradient(
    colors: [Color(0xFFFF5A7E), Color(0xFFFF3A6E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Premium ödeme kartı gradienti
  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFF201C3A), Color(0xFF2D2752), Color(0xFF1A1830)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Premium kart vurgu rengi (altın/amber)
  static const Color premiumAccent = Color(0xFFE8C97A);

  // ── Gölge Renkleri ───────────────────────────────────────────────────────

  static const Color shadowDark = Color(0x806C63FF);
  static const Color shadowLight = Color(0x20FFFFFF);
}
