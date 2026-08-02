import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../app/app_colors.dart';
import '../../../app/app_spacing.dart';
import '../../../app/app_text_styles.dart';
import '../../../app/router.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/state_widgets.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../providers/room_provider.dart';

/// Oda detay ekranı (ana hub).
///
/// Developer 2 (Room Management) bu ekranı yönetir.
///
/// Üç ana sekme:
///   - Harcamalar
///   - Bakiyeler
///   - Oda Bilgileri
///
/// TODO [Developer 2]: Bottom navigation ile sekme geçişini implement edin.
class RoomDetailScreen extends StatefulWidget {
  const RoomDetailScreen({super.key, required this.roomCode});

  final String roomCode;

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    // TODO [Developer 2]: Oda bilgilerini provider üzerinden yükleyin.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoomProvider>().loadRoomByCode(widget.roomCode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RoomProvider>(
      builder: (context, provider, _) {
        final room = provider.currentRoom;

        return Scaffold(
          backgroundColor: AppColors.backgroundDark,
          appBar: AppBar(
            title: Text(room?.name ?? 'Oda'),
            actions: [
              IconButton(
                onPressed: () {
                  // TODO [Developer 2]: Oda paylaşım modalini aç.
                },
                icon: const Icon(Icons.share_rounded),
                tooltip: 'Odayı Paylaş',
              ),
            ],
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppSpacing.maxContentWidth,
              ),
              child: provider.isLoading
                  ? const LoadingWidget(message: 'Oda yükleniyor...')
                  : provider.hasError
                      ? ErrorStateWidget(
                          message: provider.errorMessage ?? 'Oda yüklenemedi.',
                          onRetry: () =>
                              provider.loadRoomByCode(widget.roomCode),
                        )
                      : _buildBody(context, provider),
            ),
          ),
          bottomNavigationBar: _buildBottomNav(),
          floatingActionButton: _selectedTab == 0
              ? FloatingActionButton.extended(
                  onPressed: () =>
                      context.push(AppRoutes.addExpensePath(widget.roomCode)),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Harcama Ekle'),
                )
              : null,
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, RoomProvider provider) {
    return switch (_selectedTab) {
      0 => _buildExpensesTab(context),
      1 => _buildBalancesTab(context),
      2 => _buildRoomInfoTab(context, provider),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _buildExpensesTab(BuildContext context) {
    // TODO [Developer 2 + Developer 3]: ExpensesScreen'i buraya entegre edin
    //   veya doğrudan ExpensesScreen'e route edin.
    return const EmptyStateWidget(
      title: 'Henüz Harcama Yok',
      description: 'İlk harcamayı eklemek için + butonuna basın.',
      icon: Icons.receipt_long_rounded,
    );
  }

  Widget _buildBalancesTab(BuildContext context) {
    // TODO [Developer 5]: BalancesScreen'i buraya entegre edin.
    return const EmptyStateWidget(
      title: 'Bakiye Hesaplanıyor',
      description: 'Harcama eklendikten sonra bakiyeler görünecek.',
      icon: Icons.account_balance_wallet_rounded,
    );
  }

  Widget _buildRoomInfoTab(BuildContext context, RoomProvider provider) {
    final room = provider.currentRoom;
    if (room == null) return const SizedBox.shrink();

    return Padding(
      padding: AppSpacing.paddingPage,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.md),
          Text('Oda Kodu', style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textSecondary,
          )),
          const SizedBox(height: AppSpacing.sm),
          Text(room.code, style: AppTextStyles.roomCode),
          const SizedBox(height: AppSpacing.xl),
          Text('Katılımcılar (${room.members.length})', style: AppTextStyles.headlineSmall),
          const SizedBox(height: AppSpacing.md),
          ...room.members.map(
            (member) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  MemberAvatar(name: member.name),
                  const SizedBox(width: AppSpacing.md),
                  Text(member.name, style: AppTextStyles.bodyLarge),
                  if (provider.currentMember?.id == member.id) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.2),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusRound),
                      ),
                      child: Text('Ben', style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primary,
                      )),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return NavigationBar(
      selectedIndex: _selectedTab,
      onDestinationSelected: (index) => setState(() => _selectedTab = index),
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.primary.withOpacity(0.2),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.receipt_long_outlined),
          selectedIcon: Icon(Icons.receipt_long_rounded),
          label: 'Harcamalar',
        ),
        NavigationDestination(
          icon: Icon(Icons.account_balance_wallet_outlined),
          selectedIcon: Icon(Icons.account_balance_wallet_rounded),
          label: 'Bakiyeler',
        ),
        NavigationDestination(
          icon: Icon(Icons.info_outline_rounded),
          selectedIcon: Icon(Icons.info_rounded),
          label: 'Oda',
        ),
      ],
    );
  }
}
