import 'dart:js_interop';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

@JS('triggerPwaInstall')
external void _triggerPwaInstall();

/// Tarayıcı PWA kurulumunu destekliyorsa küçük bir
/// "Uygulamayı Kur" butonu gösterir. Desteklemiyorsa
/// hiçbir şey göstermez (ör. masaüstü Safari gibi).
class InstallPwaButton extends StatelessWidget {
  const InstallPwaButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () {
        try {
          _triggerPwaInstall();
        } catch (_) {
          // Tarayıcı desteklemiyorsa sessizce yok say —
          // bu SADECE görsel bir kolaylık, kritik bir işlev değil.
        }
      },
      icon: const Icon(Icons.download_rounded, color: AppColors.primary),
      label: const Text(
        'Uygulamayı Kur',
        style: TextStyle(color: AppColors.primary),
      ),
    );
  }
}