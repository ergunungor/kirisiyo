import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_theme.dart';
import 'router.dart';
import '../features/room/providers/room_provider.dart';
import '../features/expense/providers/expense_provider.dart';
import '../features/balance/providers/balance_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Kırışıyo ana uygulama widget'ı.
///
/// Tüm Provider'lar burada kayıt edilmiştir.
/// Developer 1 (Frontend Lead) bu dosyayı yönetir.
///
/// Yeni bir feature provider'ı eklerken:
/// 1. [MultiProvider] listesine ekleyin
/// 2. Gerekli repository'yi inject edin
class KirisiyoApp extends StatelessWidget {
  const KirisiyoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ── Developer 2: Oda Yönetimi ────────────────────────────────────
        ChangeNotifierProvider(create: (_) => RoomProvider()),

        // ── Developer 3: Harcama Yönetimi ────────────────────────────────
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),

        // ── Developer 5: Bakiye Motoru ────────────────────────────────────
        ChangeNotifierProvider(create: (_) => BalanceProvider()),
      ],
      child: MaterialApp.router(
        title: 'Kırışıyo',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        routerConfig: appRouter,
        // ── Lokalizasyon (Türkçe) ─────────────────────────────────────────
        locale: const Locale('tr', 'TR'),
        builder: (context, child) {
          // TODO [Developer 1]: Gerekirse global overlay'ler buraya eklenebilir
          //   Örn: connectivity banner, auth guard, etc.
          return child ?? const SizedBox.shrink();
        },

        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('tr', 'TR'), // Uygulamanın ana dili Türkçe
          Locale('en', 'US'), // Yedek olarak İngilizce
        ],
      ),
    );
  }
}
