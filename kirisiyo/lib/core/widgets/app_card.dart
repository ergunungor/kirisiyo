import 'package:flutter/material.dart';
import '../../app/app_colors.dart';
import '../../app/app_spacing.dart';

/// Kırışıyo uygulama kartı.
///
/// Tutarlı bir kart stili sağlar.
/// Developer 1 (Frontend Lead) bu widget'ı yönetir.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.elevated = false,
    this.gradient,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  /// Yükseltilmiş görünüm için true yapın.
  final bool elevated;

  /// Özel gradient arka plan.
  final Gradient? gradient;

  /// Özel kenarlık rengi.
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null
            ? (elevated ? AppColors.surfaceElevated : AppColors.surface)
            : null,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: borderColor ?? AppColors.divider,
          width: 1,
        ),
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: Padding(
            padding: padding ?? AppSpacing.paddingMd,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Gradient arka planlı öne çıkan kart.
class AppGradientCard extends StatelessWidget {
  const AppGradientCard({
    super.key,
    required this.child,
    this.gradient = AppColors.primaryGradient,
    this.padding,
    this.onTap,
  });

  final Widget child;
  final Gradient gradient;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      gradient: gradient,
      padding: padding,
      onTap: onTap,
      borderColor: Colors.transparent,
      child: child,
    );
  }
}
