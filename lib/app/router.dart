import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/splash/screens/splash_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/room/screens/create_room_screen.dart';
import '../features/room/screens/join_room_screen.dart';
import '../features/room/screens/select_member_screen.dart';
import '../features/room/screens/room_detail_screen.dart';
import '../features/expense/screens/expenses_screen.dart';
import '../features/expense/screens/add_expense_screen.dart';
import '../features/expense/screens/expense_details_screen.dart';
import '../features/balance/screens/balances_screen.dart';

/// Kırışıyo uygulama yönlendirici.
///
/// GoRouter kullanılarak tüm ekranlar bağlanmıştır.
/// Developer 1 (Frontend Lead) bu dosyayı yönetir.
/// Ekran eklerken [AppRoutes] sabitlerini kullanın.
abstract final class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';

  // ── Oda Rotaları ─────────────────────────────────────────────────────────
  static const String createRoom = '/room/create';
  static const String joinRoom = '/room/join';

  /// Parametre: [roomCode]
  static const String selectMember = '/room/:roomCode/select-member';

  /// Parametre: [roomCode]
  static const String roomDetail = '/room/:roomCode';

  // ── Harcama Rotaları ─────────────────────────────────────────────────────

  /// Parametre: [roomCode]
  static const String expenses = '/room/:roomCode/expenses';

  /// Parametre: [roomCode]
  static const String addExpense = '/room/:roomCode/expenses/add';

  /// Parametreler: [roomCode], [expenseId]
  static const String expenseDetails = '/room/:roomCode/expenses/:expenseId';

  // ── Bakiye Rotaları ──────────────────────────────────────────────────────

  /// Parametre: [roomCode]
  static const String balances = '/room/:roomCode/balances';

  // ── Fiş Tarama Rotaları ──────────────────────────────────────────────────

  // ── Yardımcı Yol Üreticiler ──────────────────────────────────────────────

  static String roomDetailPath(String roomCode) => '/room/$roomCode';
  static String selectMemberPath(String roomCode) =>
      '/room/$roomCode/select-member';
  static String expensesPath(String roomCode) => '/room/$roomCode/expenses';
  static String addExpensePath(String roomCode) =>
      '/room/$roomCode/expenses/add';
  static String expenseDetailsPath(String roomCode, String expenseId) =>
      '/room/$roomCode/expenses/$expenseId';
  static String balancesPath(String roomCode) => '/room/$roomCode/balances';
}

/// Uygulama router instance'ı.
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: true,
  routes: [
    // ── Splash ──────────────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.splash,
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),

    // ── Ana Ekran ────────────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),

    // ── Oda Yönetimi ─────────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.createRoom,
      name: 'createRoom',
      builder: (context, state) => const CreateRoomScreen(),
    ),
    GoRoute(
      path: AppRoutes.joinRoom,
      name: 'joinRoom',
      builder: (context, state) => const JoinRoomScreen(),
    ),
    GoRoute(
      path: AppRoutes.selectMember,
      name: 'selectMember',
      builder: (context, state) {
        final roomCode = state.pathParameters['roomCode']!;
        return SelectMemberScreen(roomCode: roomCode);
      },
    ),
    GoRoute(
      path: AppRoutes.roomDetail,
      name: 'roomDetail',
      builder: (context, state) {
        final roomCode = state.pathParameters['roomCode']!;
        return RoomDetailScreen(roomCode: roomCode);
      },
      routes: [
        // ── Harcamalar ─────────────────────────────────────────────────────
        GoRoute(
          path: 'expenses',
          name: 'expenses',
          builder: (context, state) {
            final roomCode = state.pathParameters['roomCode']!;
            return ExpensesScreen(roomCode: roomCode);
          },
          routes: [
            GoRoute(
              path: 'add',
              name: 'addExpense',
              builder: (context, state) {
                final roomCode = state.pathParameters['roomCode']!;
                return AddExpenseScreen(roomCode: roomCode);
              },
            ),

            GoRoute(
              path: ':expenseId',
              name: 'expenseDetails',
              builder: (context, state) {
                final roomCode = state.pathParameters['roomCode']!;
                final expenseId = state.pathParameters['expenseId']!;
                return ExpenseDetailsScreen(
                  roomCode: roomCode,
                  expenseId: expenseId,
                );
              },
            ),
          ],
        ),

        // ── Bakiyeler ──────────────────────────────────────────────────────
        GoRoute(
          path: 'balances',
          name: 'balances',
          builder: (context, state) {
            final roomCode = state.pathParameters['roomCode']!;
            return BalancesScreen(roomCode: roomCode);
          },
        ),
      ],
    ),
  ],

  errorBuilder:
      (context, state) => Scaffold(
        backgroundColor: const Color(0xFF0F0E1A),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '404',
                style: TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF6C63FF),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sayfa bulunamadı',
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.home),
                child: const Text('Ana Sayfaya Dön'),
              ),
            ],
          ),
        ),
      ),
);
