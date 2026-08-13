import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../app/app_colors.dart';
import '../../../app/app_text_styles.dart';
import '../../../app/router.dart';
import '../../../core/constants/app_constants.dart';
import 'package:provider/provider.dart';    
import '../../../core/services/local_storage_service.dart';     
import '../../room/providers/room_provider.dart';        

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
  if (!mounted) return;

  final savedRoomCode = LocalStorageService.getString(
    AppConstants.prefCurrentRoomCode,
  );

  if (savedRoomCode == null) {
    context.go(AppRoutes.home);
    return;
  }

  final roomProvider = context.read<RoomProvider>();
  await roomProvider.loadRoomByCode(savedRoomCode);

  if (!mounted) return;

  if (roomProvider.hasError || roomProvider.currentRoom == null) {
    // Oda artık yok / silinmiş → kirli kaydı temizle, home'a düş
    await LocalStorageService.remove(AppConstants.prefCurrentRoomCode);
    await LocalStorageService.remove(AppConstants.prefCurrentMemberId);
    context.go(
  AppRoutes.home,
  extra: 'Bu oda artık mevcut değil. Silinmiş olabilir.',
);
    return;
  }

  if (roomProvider.currentMember == null) {
    // Oda hâlâ var ama kayıtlı üye artık geçersiz → tekrar "kimsiniz?" sor
    context.go(AppRoutes.selectMemberPath(savedRoomCode));
    return;
  }

  // Her şey geçerli → direkt odaya düş
  context.go(AppRoutes.roomDetailPath(savedRoomCode));
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
            child: Image(
              image: AssetImage('assets/images/logo_mark.png'),
              width: 70,
              height: 70,
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
    return Text(AppConstants.appName, style: AppTextStyles.displayLarge)
        .animate(delay: 300.ms)
        .slideY(begin: 0.3, end: 0, duration: 500.ms, curve: Curves.easeOut)
        .fadeIn(duration: 400.ms);
  }

  Widget _buildTagline() {
    return Text(
      AppConstants.appTagline,
      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
      textAlign: TextAlign.center,
    ).animate(delay: 500.ms).fadeIn(duration: 400.ms);
  }
}
