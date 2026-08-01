import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class AppTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? errorText;
  final int? maxLength;
  final bool obscureText;

  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.errorText,
    this.maxLength,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      maxLength: maxLength,
      // NOT: maxLength burada SADECE arayüzde karakter sayacı gösterir.
      // Kullanıcı network isteğini manipüle ederse bu sınırı aşabilir.
      // Bu yüzden aynı sınır veritabanı tarafında (CHECK constraint)
      // da tanımlanmalıdır — Developer 5 ile koordine edilecek.
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: AppColors.border),
        ),
      ),
    );
  }
}