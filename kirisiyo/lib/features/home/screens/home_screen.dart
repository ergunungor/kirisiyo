import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../app/app_colors.dart';
import '../../../app/app_spacing.dart';
import '../../../app/app_text_styles.dart';
import '../../../app/router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_button.dart';
import '../../../shared/widgets/shared_widgets.dart';

/// Ana ekran.
///
/// "Oda Oluştur" ve "Odaya Gir" seçeneklerini sunar.
/// Developer 1 (Frontend Lead) bu ekranı yönetir.
///
/// TODO [Developer 1]: Tasarım onaylandıktan sonra
///   arka plan animasyonu eklenebilir (flutter_animate ile).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      padding: false,
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.paddingPage,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              _buildHeader(),
              const Spacer(flex: 1),
              _buildActionCards(context),
              const Spacer(flex: 2),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowDark,
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Center(
            child: Text(
              '₺',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
        const SizedBox(height: AppSpacing.lg),
        Text(
          AppConstants.appName,
          style: AppTextStyles.displayMedium,
        ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2),
        const SizedBox(height: AppSpacing.sm),
        Text(
          AppConstants.appTagline,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ).animate(delay: 300.ms).fadeIn(),
      ],
    );
  }

  Widget _buildActionCards(BuildContext context) {
    return Column(
      children: [
        // Oda Oluştur
        _HomeActionCard(
          title: 'Oda Oluştur',
          description: 'Yeni bir harcama odası oluştur ve arkadaşlarını davet et',
          icon: Icons.add_circle_rounded,
          gradient: AppColors.primaryGradient,
          onTap: () => context.push(AppRoutes.createRoom),
        ).animate(delay: 400.ms).fadeIn().slideX(begin: -0.1),

        const SizedBox(height: AppSpacing.md),

        // Odaya Gir
        _HomeActionCard(
          title: 'Odaya Gir',
          description: 'Oda kodunu girerek mevcut bir odaya katıl',
          icon: Icons.login_rounded,
          gradient: const LinearGradient(
            colors: [Color(0xFF00D4AA), Color(0xFF00A88C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          onTap: () => context.push(AppRoutes.joinRoom),
        ).animate(delay: 500.ms).fadeIn().slideX(begin: 0.1),
      ],
    );
  }

  Widget _buildFooter() {
    return Text(
      'v${AppConstants.appVersion}',
      style: AppTextStyles.bodySmall,
    ).animate(delay: 600.ms).fadeIn();
  }
}

/// Ana ekran aksiyon kartı.
class _HomeActionCard extends StatelessWidget {
  const _HomeActionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowDark,
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white.withOpacity(0.7),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
