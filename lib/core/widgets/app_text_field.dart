import 'package:flutter/material.dart';
import '../../app/app_colors.dart';
import '../../app/app_spacing.dart';
import '../../app/app_text_styles.dart';

/// Kırışıyo uygulama metin alanı.
///
/// Material 3 InputDecoration ile özelleştirilmiş metin girişi.
/// Developer 1 (Frontend Lead) bu widget'ı yönetir.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.focusNode,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.textInputAction,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.enabled = true,
    this.autofocus = false,
    this.maxLines = 1,
    this.maxLength,
    this.textCapitalization = TextCapitalization.none,
  });

  final String label;
  final String? hint;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final bool enabled;
  final bool autofocus;
  final int? maxLines;
  final int? maxLength;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      enabled: enabled,
      autofocus: autofocus,
      maxLines: maxLines,
      maxLength: maxLength,
      textCapitalization: textCapitalization,
      style: AppTextStyles.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon:
            prefixIcon != null
                ? Icon(prefixIcon, color: AppColors.textSecondary)
                : null,
        suffixIcon: suffixIcon,
        counterText: '',
      ),
    );
  }
}

/// Büyük numaral metin alanı (miktar girişi için).
class AppAmountTextField extends StatelessWidget {
  const AppAmountTextField({
    super.key,
    required this.controller,
    this.validator,
    this.onChanged,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      autofocus: autofocus,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.next,
      textAlign: TextAlign.center,
      style: AppTextStyles.amountLarge,
      decoration: InputDecoration(
        hintText: '0,00',
        hintStyle: AppTextStyles.amountLarge.copyWith(
          color: AppColors.textDisabled,
        ),
        prefixText: '₺ ',
        prefixStyle: AppTextStyles.amountLarge.copyWith(
          color: AppColors.textSecondary,
        ),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      ),
    );
  }
}

/// Oda kodu metin alanı.
class AppRoomCodeTextField extends StatelessWidget {
  const AppRoomCodeTextField({
    super.key,
    required this.controller,
    this.validator,
    this.onChanged,
    this.autofocus = true,
  });

  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      autofocus: autofocus,
      maxLength: 8,
      textCapitalization: TextCapitalization.characters,
      textAlign: TextAlign.center,
      keyboardType: TextInputType.text,
      style: AppTextStyles.roomCode,
      decoration: const InputDecoration(
        hintText: '--------',
        counterText: '',
        hintStyle: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w800,
          color: AppColors.textDisabled,
          letterSpacing: 12,
        ),
      ),
    );
  }
}
