import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../app/app_colors.dart';
import '../../../app/app_spacing.dart';
import '../../../app/app_text_styles.dart';
import '../../../app/router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../providers/room_provider.dart';

/// Odaya katılma ekranı.
///
/// Developer 2 (Room Management) bu ekranı yönetir.
///
/// Kullanıcı 6 karakterli oda kodunu girer ve odayı bulur.
class JoinRoomScreen extends StatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Odaya Gir',
      body: Consumer<RoomProvider>(
        builder: (context, provider, _) {
          return Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.login_rounded,
                  size: 64,
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Oda Kodunu Girin',
                  style: AppTextStyles.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${AppConstants.roomCodeLength} karakterli oda kodunu girin',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxl),
                AppRoomCodeTextField(
                  controller: _codeController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Oda kodu boş bırakılamaz.';
                    }
                    if (value.length != AppConstants.roomCodeLength) {
                      return '${AppConstants.roomCodeLength} karakterli kod girin.';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    if (value.length == AppConstants.roomCodeLength) {
                      // Auto-submit when code is complete
                      _joinRoom(context, provider);
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.xxl),
                AppButton(
                  label: 'Odayı Bul',
                  onPressed:
                      provider.isLoading
                          ? null
                          : () => _joinRoom(context, provider),
                  isLoading: provider.isLoading,
                  icon: Icons.search_rounded,
                ),
                if (provider.hasError) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    provider.errorMessage ?? AppConstants.errorGeneric,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.debtRed,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _joinRoom(BuildContext context, RoomProvider provider) async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.length != AppConstants.roomCodeLength) return;

    await provider.loadRoomByCode(code);

    if (!context.mounted) return;

    if (provider.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          content: Text(
            provider.errorMessage ?? AppConstants.errorRoomNotFound,
          ),
        ),
      );
      return;
    }

    if (provider.currentRoom != null) {
      context.push(AppRoutes.selectMemberPath(code));
    }
  }
}
