import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import 'app_button.dart';

class ErrorStateWidget extends StatelessWidget {
  // NOT: Buraya Supabase/PostgreSQL'in ham hata mesajı ASLA verilmeyecek.
  // Her zaman genel, kullanıcı dostu bir mesaj gösterilecek.
  // Ham hata sadece geliştirme ortamında debugPrint ile loglanmalı,
  // asla UI'da kullanıcıya gösterilmemeli.
  final String message;
  final VoidCallback? onRetry;

  const ErrorStateWidget({
    super.key,
    this.message = "Bir şeyler ters gitti. Lütfen tekrar deneyin.",
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              AppButton(text: "Tekrar Dene", onPressed: onRetry),
            ]
          ],
        ),
      ),
    );
  }
}