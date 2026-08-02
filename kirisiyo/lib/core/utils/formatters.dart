import 'package:intl/intl.dart';
import '../../core/constants/app_constants.dart';

/// Para formatlama yardımcıları.
///
/// Tüm para birimi formatlamaları bu class üzerinden yapılır.
abstract final class CurrencyFormatter {
  static final NumberFormat _format = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: AppConstants.currencySymbol,
    decimalDigits: 2,
  );

  static final NumberFormat _compact = NumberFormat.compactCurrency(
    locale: 'tr_TR',
    symbol: AppConstants.currencySymbol,
  );

  /// Tam para formatı — ₺1.234,56
  static String format(double amount) => _format.format(amount);

  /// Kompakt para formatı — ₺1,2B
  static String formatCompact(double amount) => _compact.format(amount);

  /// Pozitif/negatif renk için işaret kontrolü
  static bool isNegative(double amount) => amount < 0;
}

/// Tarih formatlama yardımcıları.
abstract final class DateFormatter {
  static final DateFormat _short = DateFormat('dd MMM', 'tr_TR');
  static final DateFormat _long = DateFormat('dd MMMM yyyy', 'tr_TR');
  static final DateFormat _relative = DateFormat('dd MMM yyyy', 'tr_TR');

  /// Kısa format — 15 Tem
  static String formatShort(DateTime date) => _short.format(date);

  /// Uzun format — 15 Temmuz 2025
  static String formatLong(DateTime date) => _long.format(date);

  /// Akıllı tarih — Bugün / Dün / tarih
  static String formatSmart(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final d = DateTime(date.year, date.month, date.day);

    if (d == today) return 'Bugün';
    if (d == yesterday) return 'Dün';
    return _relative.format(date);
  }
}

/// String yardımcıları.
abstract final class StringUtils {
  /// İlk harfi büyük yapar.
  static String capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  /// Kullanıcı adının baş harflerini döner (avatar için).
  static String initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}
