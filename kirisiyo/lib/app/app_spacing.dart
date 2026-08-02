import 'package:flutter/material.dart';

/// Kırışıyo boşluk ve boyut sistemi.
///
/// 4px tabanlı boşluk skalası kullanır.
/// Developer 1 (Frontend Lead) bu dosyayı yönetir.
abstract final class AppSpacing {
  // ── Temel Boşluk Skalası (4px tabanlı) ──────────────────────────────────

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;

  // ── Köşe Yarıçapları ─────────────────────────────────────────────────────

  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusRound = 100.0;

  // ── İkon Boyutları ───────────────────────────────────────────────────────

  static const double iconSm = 16.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;

  // ── Buton Boyutları ──────────────────────────────────────────────────────

  static const double buttonHeight = 56.0;
  static const double buttonHeightSm = 44.0;

  // ── Maksimum İçerik Genişliği (Web PWA) ─────────────────────────────────

  static const double maxContentWidth = 480.0;
  static const double maxTabletWidth = 768.0;

  // ── Yaygın EdgeInsets ────────────────────────────────────────────────────

  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);

  static const EdgeInsets paddingHorizontalMd =
      EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets paddingHorizontalLg =
      EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets paddingVerticalMd =
      EdgeInsets.symmetric(vertical: md);

  static const EdgeInsets paddingPage =
      EdgeInsets.symmetric(horizontal: lg, vertical: md);
}

/// Boşluk yardımcı widget'lar.
class AppGap {
  static const Widget xs = SizedBox(height: AppSpacing.xs);
  static const Widget sm = SizedBox(height: AppSpacing.sm);
  static const Widget md = SizedBox(height: AppSpacing.md);
  static const Widget lg = SizedBox(height: AppSpacing.lg);
  static const Widget xl = SizedBox(height: AppSpacing.xl);

  static const Widget hXs = SizedBox(width: AppSpacing.xs);
  static const Widget hSm = SizedBox(width: AppSpacing.sm);
  static const Widget hMd = SizedBox(width: AppSpacing.md);
  static const Widget hLg = SizedBox(width: AppSpacing.lg);
}
