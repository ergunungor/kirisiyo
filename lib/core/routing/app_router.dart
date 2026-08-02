import '../../features/splash/splash_screen.dart';
import '../../features/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'auth_state.dart';

class AppRouter {
  AppRouter._();

  static GoRouter router(AuthState authState) {
    return GoRouter(
      initialLocation: '/',
      refreshListenable: authState,
      routes: [
        GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
        GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
        GoRoute(path: '/create-room', builder: (context, state) => const _Placeholder(name: 'Create Room')),
        GoRoute(path: '/join-room', builder: (context, state) => const _Placeholder(name: 'Join Room')),
        GoRoute(path: '/select-member', builder: (context, state) => const _Placeholder(name: 'Select Member')),
        GoRoute(
          path: '/room/:id',
          builder: (context, state) => _Placeholder(name: 'Room ${state.pathParameters['id']}'),
        ),
        GoRoute(path: '/receipt-scanner', builder: (context, state) => const _Placeholder(name: 'Receipt Scanner')),
        GoRoute(path: '/add-expense', builder: (context, state) => const _Placeholder(name: 'Add Expense')),
        GoRoute(
          path: '/expense/:id',
          builder: (context, state) => _Placeholder(name: 'Expense ${state.pathParameters['id']}'),
        ),
      ],
      // ROUTE GUARD — burası bu adımın kalbi.
      // NOT: Bu SADECE kullanıcı deneyimi içindir. Gerçek yetki kontrolü
      // her zaman Supabase RLS tarafında yapılır. Bu guard sadece
      // yetkisiz kullanıcıya kırık bir ekran yerine düzgün bir
      // yönlendirme göstermek için var.
      redirect: (context, state) {
        final isRoomRoute = state.matchedLocation.startsWith('/room/');
        final isMember = authState.isMemberOfCurrentRoom;

        if (isRoomRoute && !isMember) {
          return '/join-room';
        }
        return null; // yönlendirme yok, olduğu gibi devam et
      },
    );
  }
}

class _Placeholder extends StatelessWidget {
  final String name;
  const _Placeholder({required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('$name ekranı (henüz boş)')),
    );
  }
}