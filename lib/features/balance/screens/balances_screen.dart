import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../app/app_colors.dart';
import '../../../app/app_spacing.dart';
import '../../../app/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/state_widgets.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../../room/providers/room_provider.dart';
import '../models/balance_model.dart';
import '../providers/balance_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';

/// Bakiyeler ekranı.
///
/// Developer 5 (Backend & Balance Engine) bu ekranı yönetir.
///
/// Gösterilenler:
///   - (Varsa) Premium ödeme talimatı kartları — kime ne kadar borçlusun
///   - Kişisel bakiye kartı
///   - Tüm üyelerin bakiyeleri
///   - Ödeme tavsiyeleri (settlements)
class BalancesScreen extends StatefulWidget {
  const BalancesScreen({super.key, required this.roomCode});

  final String roomCode;

  @override
  State<BalancesScreen> createState() => _BalancesScreenState();
}

class _BalancesScreenState extends State<BalancesScreen> {
  RealtimeChannel? _channel;
  String? _subscribedRoomId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBalances(context);
      _subscribeToChanges(context);
    });
  }

  /// Oda ile ilgili harcama/ödeme değişikliklerini canlı dinler.
  ///
  /// expense_splits tablosunda room_id kolonu olmadığı için o tabloyu
  /// filtresiz dinliyoruz (her değişiklikte bu odanın bakiyesini de
  /// yeniden hesaplıyoruz — küçük ölçekli bir uygulama için sorun değil).
  void _subscribeToChanges(BuildContext context) {
    final roomId = context.read<RoomProvider>().currentRoom?.id;
    if (roomId == null || roomId == _subscribedRoomId) return;

    _channel?.unsubscribe();
    _subscribedRoomId = roomId;

    _channel =
        SupabaseService.client
            .channel('balances-room-$roomId')
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'expenses',
              filter: PostgresChangeFilter(
                type: PostgresChangeFilterType.eq,
                column: 'room_id',
                value: roomId,
              ),
              callback: (_) => _loadBalances(context),
            )
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'expense_splits',
              callback: (_) => _loadBalances(context),
            )
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'settlements',
              filter: PostgresChangeFilter(
                type: PostgresChangeFilterType.eq,
                column: 'room_id',
                value: roomId,
              ),
              callback: (_) => _loadBalances(context),
            )
            .subscribe();
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }

  void _loadBalances(BuildContext context) {
    final roomProvider = context.read<RoomProvider>();
    final roomId = roomProvider.currentRoom?.id;
    if (roomId != null) {
      context.read<BalanceProvider>().loadAll(
        roomId: roomId,
        memberId: roomProvider.currentMember?.id,
      );
    }
  }

  Future<void> _confirmMarkPaid(BuildContext context) async {
    final roomProvider = context.read<RoomProvider>();
    final balanceProvider = context.read<BalanceProvider>();
    final roomId = roomProvider.currentRoom?.id;
    final memberId = roomProvider.currentMember?.id;
    if (roomId == null || memberId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text('Ödendi Olarak İşaretle'),
            content: const Text(
              'Borcunu ödediğini onaylıyor musun? Bu işlem bakiyeni sıfırlar. '
              'Diğer üyeler, Bakiyeler sekmesini bir sonraki açışlarında güncel '
              'bakiyeyi görecek.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Vazgeç'),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text(
                  'Ödendi',
                  style: TextStyle(color: AppColors.creditGreen),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await balanceProvider.settleAllMyDebts(
        roomId: roomId,
        memberId: memberId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(title: const Text('Bakiyeler')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppSpacing.maxContentWidth,
          ),
          child: Consumer2<BalanceProvider, RoomProvider>(
            builder: (context, provider, roomProvider, _) {
              if (provider.isLoading) {
                return const LoadingWidget(
                  message: 'Bakiyeler hesaplanıyor...',
                );
              }

              if (provider.hasError) {
                return ErrorStateWidget(
                  message: provider.errorMessage ?? 'Bakiyeler yüklenemedi.',
                  onRetry: () => _loadBalances(context),
                );
              }

              if (provider.balances.isEmpty) {
                return const EmptyStateWidget(
                  title: 'Bakiye Yok',
                  description:
                      'Harcama eklendikten sonra bakiyeler burada görünecek.',
                  icon: Icons.account_balance_wallet_rounded,
                );
              }

              final myDebts = provider.myBalance?.owes ?? const [];
              final ibanByMemberId = <String, String?>{
                for (final m in roomProvider.currentRoom?.members ?? const [])
                  m.id: m.iban,
              };

              return ListView(
                padding: AppSpacing.paddingPage,
                children: [
                  // ── Ödeme Talimatı Kartları (premium) ────────────────
                  for (final debt in myDebts) ...[
                    _PaymentInstructionCard(
                      debt: debt,
                      creditorIban: ibanByMemberId[debt.toMemberId],
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],

                  // ── Kişisel Bakiye Kartı ──────────────────────────────
                  // ── Kişisel Bakiye Kartı ──────────────────────────────
                  if (provider.myBalance != null) ...[
                    _MyBalanceCard(
                      balance: provider.myBalance!,
                      onMarkPaid: () => _confirmMarkPaid(context),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],

                  // ── Tüm Bakiyeler ─────────────────────────────────────
                  Text('Tüm Bakiyeler', style: AppTextStyles.headlineSmall),
                  const SizedBox(height: AppSpacing.md),
                  ...provider.balances.map(
                    (b) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _BalanceListTile(balance: b),
                    ),
                  ),

                  // ── Ödeme Tavsiyeleri ─────────────────────────────────
                  if (provider.settlements.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      'Ödeme Tavsiyeleri',
                      style: AppTextStyles.headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ...provider.settlements.map(
                      (s) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _SettlementCard(settlement: s),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Borçlu olunan kişiye ödeme yapmak için gösterilen premium kart.
class _PaymentInstructionCard extends StatelessWidget {
  const _PaymentInstructionCard({
    required this.debt,
    required this.creditorIban,
  });

  final DebtRecord debt;
  final String? creditorIban;

  @override
  Widget build(BuildContext context) {
    final hasIban = creditorIban != null && creditorIban!.isNotEmpty;

    return AppCard(
      gradient: AppColors.premiumGradient,
      borderColor: AppColors.premiumAccent.withOpacity(0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.workspace_premium_rounded,
                size: 18,
                color: AppColors.premiumAccent,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'ÖDEME BİLGİSİ',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.premiumAccent,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          RichText(
            text: TextSpan(
              style: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
              children: [
                TextSpan(text: '${debt.toMemberName} isimli kişiye '),
                TextSpan(
                  text: CurrencyFormatter.format(debt.amount),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const TextSpan(text: ' borçlusun'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (hasIban) ...[
            _CopyableRow(
              icon: Icons.account_balance_rounded,
              label: creditorIban!,
              copyMessage: 'IBAN kopyalandı!',
            ),
            const SizedBox(height: AppSpacing.sm),
            _CopyableRow(
              icon: Icons.person_rounded,
              label: debt.toMemberName,
              copyMessage: 'İsim kopyalandı!',
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Borcunu bu bilgiler ile ödeyebilirsin.',
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ] else
            Text(
              '${debt.toMemberName} henüz IBAN bilgisini eklemedi.',
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
            ),
        ],
      ),
    );
  }
}

/// Kopyalanabilir bilgi satırı (IBAN / isim).
class _CopyableRow extends StatelessWidget {
  const _CopyableRow({
    required this.icon,
    required this.label,
    required this.copyMessage,
  });

  final IconData icon;
  final String label;
  final String copyMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.premiumAccent),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.labelLarge.copyWith(
                color: Colors.white,
                letterSpacing: 0.5,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.copy_rounded,
              size: 18,
              color: AppColors.premiumAccent,
            ),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: label));
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(copyMessage)));
              }
            },
          ),
        ],
      ),
    );
  }
}

/// Kişisel bakiye kartı.
class _MyBalanceCard extends StatelessWidget {
  const _MyBalanceCard({required this.balance, this.onMarkPaid});
  final BalanceModel balance;
  final VoidCallback? onMarkPaid;

  @override
  Widget build(BuildContext context) {
    final isInDebt = balance.isInDebt;

    return AppGradientCard(
      gradient: isInDebt ? AppColors.debtGradient : AppColors.creditGradient,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Benim Bakiyem',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  CurrencyFormatter.format(balance.netBalance),
                  style: AppTextStyles.amountLarge.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  isInDebt
                      ? '${balance.owes.length} kişiye borçlusun'
                      : balance.isInCredit
                      ? '${balance.isOwed.length} kişi sana borçlu'
                      : 'Bakiyen sıfır 🎉',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          if (isInDebt && onMarkPaid != null) ...[
            const SizedBox(width: AppSpacing.sm),
            _MarkPaidButton(onPressed: onMarkPaid!),
          ],
        ],
      ),
    );
  }
}

/// "Ödendi" butonu — bakiye kartının sağında gösterilir.
class _MarkPaidButton extends StatelessWidget {
  const _MarkPaidButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.18),
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        onTap: onPressed,
        child: const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
              SizedBox(height: 2),
              Text(
                'Ödendi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Üye bakiye satırı.
class _BalanceListTile extends StatelessWidget {
  const _BalanceListTile({required this.balance});
  final BalanceModel balance;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          MemberAvatar(name: balance.memberName),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(balance.memberName, style: AppTextStyles.labelLarge),
          ),
          AmountDisplay(amount: balance.netBalance),
        ],
      ),
    );
  }
}

/// Ödeme tavsiyesi kartı.
class _SettlementCard extends StatelessWidget {
  const _SettlementCard({required this.settlement});
  final SettlementModel settlement;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          MemberAvatar(name: settlement.fromMemberName, size: AvatarSize.small),
          const SizedBox(width: AppSpacing.sm),
          const Icon(
            Icons.arrow_forward_rounded,
            size: 16,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: AppSpacing.sm),
          MemberAvatar(name: settlement.toMemberName, size: AvatarSize.small),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${settlement.fromMemberName} → ${settlement.toMemberName}',
                  style: AppTextStyles.labelMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            CurrencyFormatter.format(settlement.amount),
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.creditGreen,
            ),
          ),
        ],
      ),
    );
  }
}
