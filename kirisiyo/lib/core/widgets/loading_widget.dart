import 'package:flutter/material.dart';
import '../../app/app_colors.dart';
import '../../app/app_spacing.dart';
import '../../app/app_text_styles.dart';

/// Yükleme durumu widget'ı.
///
/// Sayfa veya veri yüklenirken gösterilir.
/// Developer 1 (Frontend Lead) bu widget'ı yönetir.
class LoadingWidget extends StatelessWidget {
  const LoadingWidget({
    super.key,
    this.message = 'Yükleniyor...',
    this.size = LoadingSize.medium,
  });

  final String message;
  final LoadingSize size;

  @override
  Widget build(BuildContext context) {
    final indicatorSize = switch (size) {
      LoadingSize.small => 24.0,
      LoadingSize.medium => 40.0,
      LoadingSize.large => 56.0,
    };

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: indicatorSize,
            height: indicatorSize,
            child: CircularProgressIndicator(
              strokeWidth: size == LoadingSize.small ? 2 : 3,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
          if (message.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

enum LoadingSize { small, medium, large }

/// Shimmer yükleme efekti.
///
/// Liste öğeleri yüklenirken iskelet gösterim için.
class LoadingShimmerCard extends StatelessWidget {
  const LoadingShimmerCard({super.key, this.height = 80});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      // TODO [Developer 1]: shimmer paketi ile animasyon ekle.
    );
  }
}

/// Tam ekran yükleme overlay'i.
class FullScreenLoadingWidget extends StatelessWidget {
  const FullScreenLoadingWidget({
    super.key,
    this.message = 'Lütfen bekleyin...',
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark.withOpacity(0.85),
      body: LoadingWidget(message: message, size: LoadingSize.large),
    );
  }
}
