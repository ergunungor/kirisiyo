import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../app/app_colors.dart';
import '../../../app/app_spacing.dart';
import '../../../app/app_text_styles.dart';
import '../../../app/router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/state_widgets.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../providers/room_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Oda oluşturma ekranı.
///
/// Developer 2 (Room Management) bu ekranı yönetir.
///
/// Adımlar:
///   1. Oda adı girişi
///   2. Katılımcı isimleri girişi
///   3. Oda kodu üretme ve paylaşım
class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _roomNameController = TextEditingController();
  final _memberNameController = TextEditingController();
  final _memberNameFocusNode = FocusNode();

  @override
  void dispose() {
    _roomNameController.dispose();
    _memberNameController.dispose();
    _memberNameFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Oda Oluştur',
      body: Consumer<RoomProvider>(
        builder: (context, provider, _) {
          if (provider.status == RoomStatus.success &&
              provider.generatedRoomCode != null) {
            return _buildSuccessView(context, provider);
          }

          return Form(
            key: _formKey,
            child: ListView(
              children: [
                const SizedBox(height: AppSpacing.md),
                _buildRoomNameSection(context, provider),
                const SizedBox(height: AppSpacing.xl),
                _buildMembersSection(context, provider),
                const SizedBox(height: AppSpacing.xl),
                _buildCreateButton(context, provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoomNameSection(BuildContext context, RoomProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Oda Adı', style: AppTextStyles.headlineSmall),
        const SizedBox(height: AppSpacing.sm),
        AppTextField(
          label: 'Oda adını girin',
          hint: 'Örn: Yaz tatili, Hafta sonu gezisi',
          controller: _roomNameController,

          prefixIcon: Icons.meeting_room_rounded,
          maxLength: AppConstants.roomNameMaxLength,
          textCapitalization: TextCapitalization.sentences,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Oda adı boş bırakılamaz.';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildMembersSection(BuildContext context, RoomProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Katılımcılar (${provider.pendingMemberNames.length}/${AppConstants.maxParticipants})',
          style: AppTextStyles.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                label: 'Katılımcı adı',
                hint: 'İsim girin',
                controller: _memberNameController,
                focusNode: _memberNameFocusNode,
                prefixIcon: Icons.person_add_rounded,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _addMember(context, provider),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            _AddMemberButton(onPressed: () => _addMember(context, provider)),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        // Üye listesi
        ...provider.pendingMemberNames.asMap().entries.map(
          (entry) => _MemberChip(
            name: entry.value,
            onRemove: () => provider.removeMemberName(entry.key),
          ),
        ),
        if (provider.pendingMemberNames.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Text(
              'En az bir katılımcı ekleyin.',
              style: AppTextStyles.bodySmall,
            ),
          ),
      ],
    );
  }

  Widget _buildCreateButton(BuildContext context, RoomProvider provider) {
    return AppButton(
      label: 'Oda Oluştur',
      onPressed:
          provider.isLoading ? null : () => _createRoom(context, provider),
      isLoading: provider.isLoading,
      icon: Icons.rocket_launch_rounded,
    );
  }

  Widget _buildSuccessView(BuildContext context, RoomProvider provider) {
    final code = provider.generatedRoomCode!;
    final shareLink = AppConstants.roomInviteLink(code);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            size: 80,
            color: AppColors.creditGreen,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Oda Oluşturuldu!', style: AppTextStyles.headlineLarge),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Oda Kodu',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(code, style: AppTextStyles.roomCode),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: 'Odaya Git',
            onPressed: () => context.go(AppRoutes.selectMemberPath(code)),
            icon: Icons.arrow_forward_rounded,
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: 'Bağlantıyı Paylaş',
            onPressed: () async {
              await Share.share(
                'Kırışıyo grubuna katıl ve ortak harcamaları birlikte yönetelim!\n\nKatılım Bağlantısı: $shareLink',
                subject: 'Kırışıyo Oda Daveti',
              );
            },
            icon: Icons.ios_share_rounded,
          ),
        ],
      ),
    );
  }

  void _addMember(BuildContext context, RoomProvider provider) {
    final name = _memberNameController.text.trim();
    if (name.isEmpty) return;
    provider.addMemberName(name);
    _memberNameController.clear();
    _memberNameFocusNode.requestFocus();
  }

  Future<void> _createRoom(BuildContext context, RoomProvider provider) async {
    if (!_formKey.currentState!.validate()) return;
    if (provider.pendingMemberNames.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: const Duration(seconds: 2),
          content: Text('En az bir katılımcı ekleyin.'),
        ),
      );
      return;
    }

    await provider.createRoom(
      name: _roomNameController.text.trim(),
      memberNames: provider.pendingMemberNames,
    );

    if (provider.hasError && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          content: Text(provider.errorMessage ?? AppConstants.errorGeneric),
        ),
      );
    }
  }
}

class _AddMemberButton extends StatelessWidget {
  const _AddMemberButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }
}

class _MemberChip extends StatelessWidget {
  const _MemberChip({required this.name, required this.onRemove});
  final String name;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          MemberAvatar(name: name, size: AvatarSize.small),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(name, style: AppTextStyles.bodyMedium)),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.close_rounded, size: 18),
            color: AppColors.textSecondary,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
