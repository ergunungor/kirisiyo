import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'core/routing/auth_state.dart';

void main() {
  usePathUrlStrategy();
  runApp(const KirisiyoApp());
}

class KirisiyoApp extends StatefulWidget {
  const KirisiyoApp({super.key});

  @override
  State<KirisiyoApp> createState() => _KirisiyoAppState();
}

class _KirisiyoAppState extends State<KirisiyoApp> {
  final AuthState _authState = AuthState();

  @override
  Widget build(BuildContext context) {
    final router = AppRouter.router(_authState);

    return MaterialApp.router(
      title: 'Kirisiyo',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}