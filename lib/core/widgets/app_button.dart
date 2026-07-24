import 'package:flutter/material.dart';
import '../../app/app_colors.dart';
import '../../app/app_spacing.dart';
import '../../app/app_text_styles.dart';

/// Kırışıyo uygulama butonu.
///
/// [variant] ile buton tipini belirleyin:
/// - [AppButtonVariant.primary]: Gradient birincil buton
/// - [AppButtonVariant.secondary]: Kenarlıklı ikincil buton
/// - [AppButtonVariant.ghost]: Arka plansız buton
/// - [AppButtonVariant.danger]: Silme/iptal işlemleri için
///
/// Developer 1 (Frontend Lead) bu widget'ı yönetir.
enum AppButtonVariant { primary, secondary, ghost, danger }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.size = AppButtonSize.medium,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final AppButtonSize size;

  @override
  Widget build(BuildContext context) {
    final height = size == AppButtonSize.small
        ? AppSpacing.buttonHeightSm
        : AppSpacing.buttonHeight;

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: height,
      child: _buildButton(),
    );
  }

  Widget _buildButton() {
    switch (variant) {
      case AppButtonVariant.primary:
        return _PrimaryButton(
          label: label,
          onPressed: isLoading ? null : onPressed,
          icon: icon,
          isLoading: isLoading,
        );
      case AppButtonVariant.secondary:
        return _SecondaryButton(
          label: label,
          onPressed: isLoading ? null : onPressed,
          icon: icon,
        );
      case AppButtonVariant.ghost:
        return _GhostButton(
          label: label,
          onPressed: isLoading ? null : onPressed,
          icon: icon,
        );
      case AppButtonVariant.danger:
        return _DangerButton(
          label: label,
          onPressed: isLoading ? null : onPressed,
          icon: icon,
        );
    }
  }
}

enum AppButtonSize { small, medium }

// ── İç Buton Implementasyonları ───────────────────────────────────────────────

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: onPressed == null
            ? null
            : AppColors.primaryGradient,
        color: onPressed == null ? AppColors.textDisabled : null,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: onPressed == null
            ? null
            : [
                BoxShadow(
                  color: AppColors.shadowDark,
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: 20, color: Colors.white),
                        const SizedBox(width: AppSpacing.sm),
                      ],
                      Text(label, style: AppTextStyles.labelLarge),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: icon != null ? Icon(icon, size: 20) : const SizedBox.shrink(),
      label: Text(label),
    );
  }
}

class _GhostButton extends StatelessWidget {
  const _GhostButton({
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: icon != null ? Icon(icon, size: 20) : const SizedBox.shrink(),
      label: Text(label),
    );
  }
}

class _DangerButton extends StatelessWidget {
  const _DangerButton({
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.debtRed,
        foregroundColor: Colors.white,
      ),
      icon: icon != null ? Icon(icon, size: 20) : const SizedBox.shrink(),
      label: Text(label),
    );
  }
}
