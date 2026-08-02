import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../app/app_colors.dart';
import '../../../app/app_text_styles.dart';
import '../../../app/router.dart';
import '../../../core/constants/app_constants.dart';

/// Splash ekranı.
///
/// Uygulama açılışında gösterilen animasyonlu logo ekranı.
/// Developer 1 (Frontend Lead) bu ekranı yönetir.
///
/// TODO [Developer 1]: Logo asset'i hazır olduğunda
///   [_buildLogo] metodunu güncelleyin.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(AppConstants.splashDuration);
    if (mounted) {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLogo(),
            const SizedBox(height: 24),
            _buildAppName(),
            const SizedBox(height: 8),
            _buildTagline(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    // TODO [Developer 1]: Gerçek logo asset'i buraya ekleyin.
    //   Image.asset('assets/images/logo.png') veya SVG kullanın.
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDark,
            blurRadius: 40,
            spreadRadius: 8,
          ),
        ],
      ),
      child: const Center(
        child: Text(
          '₺',
          style: TextStyle(
            fontSize: 56,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    )
        .animate()
        .scale(
          duration: 600.ms,
          curve: Curves.elasticOut,
          begin: const Offset(0, 0),
          end: const Offset(1, 1),
        )
        .fadeIn(duration: 400.ms);
  }

  Widget _buildAppName() {
    return Text(
      AppConstants.appName,
      style: AppTextStyles.displayLarge,
    )
        .animate(delay: 300.ms)
        .slideY(
          begin: 0.3,
          end: 0,
          duration: 500.ms,
          curve: Curves.easeOut,
        )
        .fadeIn(duration: 400.ms);
  }

  Widget _buildTagline() {
    return Text(
      AppConstants.appTagline,
      style: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textSecondary,
      ),
      textAlign: TextAlign.center,
    )
        .animate(delay: 500.ms)
        .fadeIn(duration: 400.ms);
  }
}
