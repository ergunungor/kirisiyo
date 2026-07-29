import 'package:flutter/material.dart';
import 'package:kirisiyo/features/receipt_scanner/services/ocr_service.dart';
import 'package:provider/provider.dart';
import 'app_theme.dart';
import 'router.dart';
import '../features/room/providers/room_provider.dart';
import '../features/expense/providers/expense_provider.dart';
import '../features/balance/providers/balance_provider.dart';
import '../features/receipt_scanner/providers/receipt_scanner_provider.dart';
import '../features/receipt_scanner/screens/receipt_scanner_screen.dart';

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

        // ── Developer 4: Fiş Tarayıcı ────────────────────────────────────
        ChangeNotifierProvider(
          create:
              (_) => ReceiptScannerProvider(ocrService: const MockOcrService()),
        ),
      ],
      child: MaterialApp(
        title: 'Kırışıyo',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,

        // ── GoRouter Bağlantısı ───────────────────────────────────────────
        // routerConfig: appRouter,
        home: const ReceiptScannerScreen(roomCode: '123456'),
        // ── Lokalizasyon (Türkçe) ─────────────────────────────────────────
        locale: const Locale('tr', 'TR'),
        builder: (context, child) {
          // TODO [Developer 1]: Gerekirse global overlay'ler buraya eklenebilir
          //   Örn: connectivity banner, auth guard, etc.
          return child ?? const SizedBox.shrink();
        },
      ),
    );
  }
}
