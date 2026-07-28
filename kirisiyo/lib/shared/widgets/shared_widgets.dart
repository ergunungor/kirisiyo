import 'package:flutter/material.dart';
import '../../app/app_colors.dart';
import '../../app/app_spacing.dart';
import '../../app/app_text_styles.dart';

/// Üye avatar widget'ı.
///
/// Üye isminin baş harflerini renkli arka planla gösterir.
class MemberAvatar extends StatelessWidget {
  const MemberAvatar({
    super.key,
    required this.name,
    this.size = AvatarSize.medium,
    this.isSelected = false,
  });

  final String name;
  final AvatarSize size;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final dim = switch (size) {
      AvatarSize.small => 32.0,
      AvatarSize.medium => 44.0,
      AvatarSize.large => 64.0,
    };
    final fontSize = switch (size) {
      AvatarSize.small => 12.0,
      AvatarSize.medium => 16.0,
      AvatarSize.large => 22.0,
    };

    final initials = _initials(name);
    final color = _colorFromName(name);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: dim,
      height: dim,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        border: isSelected
            ? Border.all(color: AppColors.primary, width: 2.5)
            : null,
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.4),
                  blurRadius: 8,
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            fontFamily: 'Nunito',
          ),
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  Color _colorFromName(String name) {
    const colors = [
      Color(0xFF6C63FF),
      Color(0xFF00D4AA),
      Color(0xFFFF6B6B),
      Color(0xFFFFD93D),
      Color(0xFF4FC3F7),
      Color(0xFFAB47BC),
      Color(0xFF26A69A),
      Color(0xFFEF5350),
    ];
    final index = name.codeUnits.fold(0, (a, b) => a + b) % colors.length;
    return colors[index];
  }
}

enum AvatarSize { small, medium, large }

/// Para miktarı görüntüleme widget'ı.
///
/// Pozitif/negatif bakiye için renklendirme yapar.
class AmountDisplay extends StatelessWidget {
  const AmountDisplay({
    super.key,
    required this.amount,
    this.style,
    this.showSign = true,
  });

  final double amount;
  final TextStyle? style;
  final bool showSign;

  @override
  Widget build(BuildContext context) {
    final isNegative = amount < 0;
    final color = isNegative ? AppColors.debtRed : AppColors.creditGreen;
    final sign = showSign && !isNegative ? '+' : '';
    final absAmount = amount.abs();

    return Text(
      '$sign₺${absAmount.toStringAsFixed(2)}',
      style: (style ?? AppTextStyles.bodyLarge).copyWith(color: color),
    );
  }
}

/// Kırışıyo sayfa scaffold'u.
///
/// Tutarlı sayfa yapısı için wrapper.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.resizeToAvoidBottomInset = true,
    this.padding = true,
  });

  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final bool resizeToAvoidBottomInset;
  final bool padding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: title != null
          ? AppBar(
              title: Text(title!),
              actions: actions,
            )
          : null,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppSpacing.maxContentWidth,
          ),
          child: padding
              ? Padding(
                  padding: AppSpacing.paddingPage,
                  child: body,
                )
              : body,
        ),
      ),
    );
  }
}
