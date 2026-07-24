import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/app_colors.dart';
import '../../../app/app_spacing.dart';
import '../../../app/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/state_widgets.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../providers/receipt_scanner_provider.dart';

/// Fiş tarama ekranı.
///
/// Developer 4 (AI Receipt Scanner) bu ekranı yönetir.
///
/// Seçenekler:
///   - Kameradan fotoğraf çek
///   - Galeriden fotoğraf seç
///
/// Tarama sonrası:
///   - Merchant name göster
///   - Total amount göster
///   - "Harcamaya Ekle" butonu
///
/// TODO [Developer 4]: Provider bağlantısını ve sonuç UI'ını tamamlayın.
class ReceiptScannerScreen extends StatelessWidget {
  const ReceiptScannerScreen({super.key, required this.roomCode});

  final String roomCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Fiş Tara'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
          child: Consumer<ReceiptScannerProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return _buildLoadingView(provider);
              }

              if (provider.hasError) {
                return ErrorStateWidget(
                  message: provider.errorMessage ?? 'Tarama başarısız.',
                  onRetry: provider.reset,
                );
              }

              if (provider.scanResult?.hasData == true) {
                return _buildResultView(context, provider);
              }

              return _buildScanOptions(context, provider);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildScanOptions(
      BuildContext context, ReceiptScannerProvider provider) {
    return Padding(
      padding: AppSpacing.paddingPage,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
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
            child: const Icon(
              Icons.document_scanner_rounded,
              size: 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Fişi Tara',
            style: AppTextStyles.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Fişi veya makbuzu tara, toplam tutarı otomatik algıla',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxl),
          AppButton(
            label: 'Kameradan Çek',
            onPressed: () =>
                provider.scanFromCamera(roomId: roomCode),
            icon: Icons.camera_alt_rounded,
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: 'Galeriden Seç',
            variant: AppButtonVariant.secondary,
            onPressed: () =>
                provider.scanFromGallery(roomId: roomCode),
            icon: Icons.photo_library_rounded,
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Desteklenen formatlar: JPG, PNG, HEIC',
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView(ReceiptScannerProvider provider) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 60,
          height: 60,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          provider.statusMessage ?? 'İşleniyor...',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildResultView(
      BuildContext context, ReceiptScannerProvider provider) {
    final result = provider.scanResult!;

    return Padding(
      padding: AppSpacing.paddingPage,
      child: Column(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            size: 64,
            color: AppColors.creditGreen,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Fiş Algılandı!', style: AppTextStyles.headlineLarge),
          const SizedBox(height: AppSpacing.xl),

          // Sonuç kartı
          Container(
            width: double.infinity,
            padding: AppSpacing.paddingLg,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (result.merchantName != null) ...[
                  Text('İşletme', style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  )),
                  const SizedBox(height: 4),
                  Text(result.merchantName!, style: AppTextStyles.headlineMedium),
                  const SizedBox(height: AppSpacing.md),
                ],
                if (result.totalAmount != null) ...[
                  Text('Toplam', style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  )),
                  const SizedBox(height: 4),
                  Text(
                    '₺${result.totalAmount!.toStringAsFixed(2)}',
                    style: AppTextStyles.amountLarge,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          AppButton(
            label: 'Harcamaya Ekle',
            onPressed: () {
              // TODO [Developer 4]: Sonucu AddExpenseScreen'e aktar.
              //   context.pop(result) ve AddExpenseScreen'de await ile al.
              Navigator.of(context).pop(result);
            },
            icon: Icons.add_rounded,
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: 'Tekrar Tara',
            variant: AppButtonVariant.ghost,
            onPressed: provider.reset,
            icon: Icons.refresh_rounded,
          ),
        ],
      ),
    );
  }
}
