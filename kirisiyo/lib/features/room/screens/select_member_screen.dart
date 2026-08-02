import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../app/app_colors.dart';
import '../../../app/app_spacing.dart';
import '../../../app/app_text_styles.dart';
import '../../../app/router.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/state_widgets.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../models/room_model.dart';
import '../providers/room_provider.dart';

/// Üye seçim ekranı.
///
/// Developer 2 (Room Management) bu ekranı yönetir.
///
/// Odaya giren kullanıcı kimliğini seçer.
class SelectMemberScreen extends StatelessWidget {
  const SelectMemberScreen({super.key, required this.roomCode});

  final String roomCode;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Kimsiniz?',
      body: Consumer<RoomProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const LoadingWidget(message: 'Oda üyeleri yükleniyor...');
          }

          final room = provider.currentRoom;

          if (room == null || provider.hasError) {
            return ErrorStateWidget(
              message: provider.errorMessage ?? 'Oda bilgisi yüklenemedi.',
              onRetry: () => provider.loadRoomByCode(roomCode),
            );
          }

          if (room.members.isEmpty) {
            return const EmptyStateWidget(
              title: 'Üye Bulunamadı',
              description: 'Bu odada henüz üye yok.',
              icon: Icons.group_off_rounded,
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                room.name,
                style: AppTextStyles.headlineLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Listeden kendinizi seçin',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Expanded(
                child: ListView.separated(
                  itemCount: room.members.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final member = room.members[index];
                    final isSelected =
                        provider.currentMember?.id == member.id;

                    return _MemberListTile(
                      member: member,
                      isSelected: isSelected,
                      onTap: () => provider.selectMember(member),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: 'Devam Et',
                onPressed: provider.currentMember == null
                    ? null
                    : () => context.go(AppRoutes.roomDetailPath(roomCode)),
                icon: Icons.arrow_forward_rounded,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MemberListTile extends StatelessWidget {
  const _MemberListTile({
    required this.member,
    required this.isSelected,
    required this.onTap,
  });

  final MemberModel member;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withOpacity(0.15)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.divider,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: MemberAvatar(
          name: member.name,
          isSelected: isSelected,
        ),
        title: Text(member.name, style: AppTextStyles.labelLarge),
        trailing: isSelected
            ? const Icon(Icons.check_circle_rounded,
                color: AppColors.primary)
            : null,
      ),
    );
  }
}
