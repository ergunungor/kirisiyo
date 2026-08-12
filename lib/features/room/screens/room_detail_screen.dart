import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kirisiyo/core/constants/app_constants.dart';
import 'package:provider/provider.dart';
import '../../../app/app_colors.dart';
import '../../../app/app_spacing.dart';
import '../../../app/app_text_styles.dart';
import '../../../app/router.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/state_widgets.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../providers/room_provider.dart';
import 'package:flutter/services.dart';
import '../../expense/screens/expenses_screen.dart';
import '../../../core/widgets/app_button.dart';
import '../../balance/screens/balances_screen.dart';
import '../../../core/widgets/app_text_field.dart';
import 'package:kirisiyo/core/services/local_storage_service.dart';
import '../../../shared/widgets/liquid_glass_nav_bar.dart';

/// Oda detay ekranı (ana hub).
///
/// Developer 2 (Room Management) bu ekranı yönetir.
///
/// Üç ana sekme:
///   - Harcamalar
///   - Bakiyeler
///   - Oda Bilgileri
///

class RoomDetailScreen extends StatefulWidget {
  const RoomDetailScreen({super.key, required this.roomCode});

  final String roomCode;

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  int _selectedTab = 0;
  final _fullNameController = TextEditingController();
  final _ibanController = TextEditingController();
  bool _ibanInitialized = false;

  @override
void initState() {
  super.initState();

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final roomProvider = context.read<RoomProvider>();
    await roomProvider.loadRoomByCode(widget.roomCode);
    if (!mounted) return;

    if (roomProvider.hasError || roomProvider.currentRoom == null) {
      // Oda silinmiş — kirli local kaydı temizle, ana sayfaya dön
      await LocalStorageService.remove(AppConstants.prefCurrentRoomCode);
      await LocalStorageService.remove(AppConstants.prefCurrentMemberId);
      if (!mounted) return;
      context.go(
  AppRoutes.home,
  extra: 'Bu oda artık mevcut değil. Silinmiş olabilir.',
);
      return;
    }

    if (roomProvider.currentMember == null) {
      // Oda var ama kayıtlı üye artık geçersiz — tekrar sor
      context.go(AppRoutes.selectMemberPath(widget.roomCode));
    }
  });
}

  @override
  void dispose() {
    _fullNameController.dispose();
    _ibanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RoomProvider>(
      builder: (context, provider, _) {
        final room = provider.currentRoom;

        return Scaffold(
          backgroundColor: AppColors.backgroundDark,
          appBar: AppBar(
            title: Text(
              room?.name ?? 'Oda',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            actions: [
              IconButton(
                onPressed: () async {
                  // Senin bulduğun AppConstants metodunu çağırıyoruz
                  final shareLink = AppConstants.roomInviteLink(
                    widget.roomCode,
                  );
                  await Clipboard.setData(ClipboardData(text: shareLink));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        duration: Duration(seconds: 2),
                        content: Text('Davet bağlantısı kopyalandı!'),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.ios_share_rounded),
                tooltip: 'Odayı Paylaş',
              ),
            ],
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppSpacing.maxContentWidth,
              ),
              child:
                  provider.isLoading
                      ? const LoadingWidget(message: 'Oda yükleniyor...')
                      : provider.hasError
                      ? ErrorStateWidget(
                        message: provider.errorMessage ?? 'Oda yüklenemedi.',
                        onRetry: () => provider.loadRoomByCode(widget.roomCode),
                      )
                      : _buildBody(context, provider),
            ),
          ),
          bottomNavigationBar: _buildBottomNav(),
          floatingActionButton:
              _selectedTab == 0
                  ? FloatingActionButton.extended(
                    onPressed:
                        () => context.push(
                          AppRoutes.addExpensePath(widget.roomCode),
                        ),
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
    return ExpensesScreen(roomCode: widget.roomCode, embedded: true);
  }

  Widget _buildBalancesTab(BuildContext context) {
    return BalancesScreen(roomCode: widget.roomCode, embedded: true);
  }

  Widget _buildRoomInfoTab(BuildContext context, RoomProvider provider) {
    final room = provider.currentRoom;
    if (room == null) return const SizedBox.shrink();

    if (!_ibanInitialized) {
      _fullNameController.text = provider.currentMember?.fullName ?? '';
      _ibanController.text = provider.currentMember?.iban ?? '';
      _ibanInitialized = true;
    }

    return SingleChildScrollView(
      child: Padding(
        padding: AppSpacing.paddingPage,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.md),
            Text(
              'Oda Kodu',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(room.code, style: AppTextStyles.roomCode),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Katılımcılar (${room.members.length})',
              style: AppTextStyles.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.md),
            ...room.members.map(
              (member) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  children: [
                    MemberAvatar(name: member.name),
                    const SizedBox(width: AppSpacing.md),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(member.name, style: AppTextStyles.bodyLarge),
                        if (member.fullName != null &&
                            member.fullName!.isNotEmpty)
                          Text(
                            member.fullName!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                    if (provider.currentMember?.id == member.id) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusRound,
                          ),
                        ),
                        child: Text(
                          'Ben',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // ── Ödeme Bilgileri (Ad Soyad + IBAN) ──
            const SizedBox(height: AppSpacing.xl),
            Text('Ödeme Bilgilerin', style: AppTextStyles.headlineSmall),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Sana borcu olanlar transfer yaparken bu Ad Soyad ve IBAN bilgilerini görsün.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Ad Soyad (Banka Hesabı Sahibi)',
              hint: 'Örn: Ahmet Yılmaz',
              controller: _fullNameController,
              prefixIcon: Icons.badge_rounded,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'IBAN',
              hint: 'TR00 0000 0000 0000 0000 0000 00',
              controller: _ibanController,
              prefixIcon: Icons.account_balance_rounded,
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: 'Bilgileri Kaydet',
              variant: AppButtonVariant.secondary,
              icon: Icons.save_rounded,
              isFullWidth: false,
              onPressed: () => _savePaymentInfo(context, provider),
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Odadan Çık Butonu ──
            AppButton(
              label: 'Odadan Çık',
              variant: AppButtonVariant.danger,
              icon: Icons.logout_rounded,
              onPressed: () => _confirmLeaveRoom(context, provider),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Future<void> _savePaymentInfo(
    BuildContext context,
    RoomProvider provider,
  ) async {
    final fullName = _fullNameController.text.trim();
    final rawIban = _ibanController.text.trim().toUpperCase().replaceAll(
      ' ',
      '',
    );

    if (rawIban.isNotEmpty && !RegExp(r'^TR\d{24}$').hasMatch(rawIban)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 2),
          content: Text(
            'Geçerli bir IBAN girin (TR ile başlamalı, 26 karakter).',
          ),
        ),
      );
      return;
    }

    await provider.updateMyPaymentInfo(
      fullName: fullName.isEmpty ? null : fullName,
      iban: rawIban.isEmpty ? null : rawIban,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 2),
          content: Text(
            provider.hasError
                ? (provider.errorMessage ?? 'Bilgiler kaydedilemedi.')
                : 'Ödeme bilgilerin kaydedildi.',
          ),
        ),
      );
    }
  }

  Future<void> _confirmLeaveRoom(
    BuildContext context,
    RoomProvider provider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text('Odadan Çık'),
            content: const Text(
              'Bu odadan çıkmak istediğine emin misin? Tekrar girmek için oda koduna ihtiyacın olacak.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Vazgeç'),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text(
                  'Odadan Çık',
                  style: TextStyle(color: AppColors.debtRed),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await provider.leaveRoom();
      if (context.mounted) {
        context.go(AppRoutes.home);
      }
    }
  }

  Widget _buildBottomNav() {
    return LiquidGlassNavBar(
      selectedIndex: _selectedTab,
      onDestinationSelected: (index) => setState(() => _selectedTab = index),
      items: const [
        LiquidNavItem(
          icon: Icons.view_agenda_outlined,
          selectedIcon: Icons.view_agenda_rounded,
          label: 'Harcamalar',
        ),
        LiquidNavItem(
          icon: Icons.pie_chart_outline_rounded,
          selectedIcon: Icons.pie_chart_rounded,
          label: 'Bakiyeler',
        ),
        LiquidNavItem(
          icon: Icons.diversity_3_outlined,
          selectedIcon: Icons.diversity_3_rounded,
          label: 'Üyeler',
        ),
      ],
    );
  }
}
