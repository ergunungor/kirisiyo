import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/app_colors.dart';
import '../../../app/app_spacing.dart';
import '../../../app/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/state_widgets.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../models/balance_model.dart';
import '../providers/balance_provider.dart';

/// Bakiyeler ekranı.
///
/// Developer 5 (Backend & Balance Engine) bu ekranı yönetir.
///
/// Gösterilenler:
///   - Kişisel bakiye kartı
///   - Tüm üyelerin bakiyeleri
///   - Ödeme tavsiyeleri (settlements)
///
/// TODO [Developer 5]: Gerçek veriyi provider üzerinden yükleyin.
class BalancesScreen extends StatefulWidget {
  const BalancesScreen({super.key, required this.roomCode});

  final String roomCode;

  @override
  State<BalancesScreen> createState() => _BalancesScreenState();
}

class _BalancesScreenState extends State<BalancesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // TODO [Developer 5]: Bakiyeleri ve ödeme tavsiyelerini yükleyin.
      // context.read<BalanceProvider>().loadAll(roomId: roomId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Bakiyeler'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
          child: Consumer<BalanceProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const LoadingWidget(message: 'Bakiyeler hesaplanıyor...');
              }

              if (provider.hasError) {
                return ErrorStateWidget(
                  message: provider.errorMessage ?? 'Bakiyeler yüklenemedi.',
                  onRetry: () {
                    // TODO [Developer 5]: loadAll() çağırın
                  },
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

              return ListView(
                padding: AppSpacing.paddingPage,
                children: [
                  // ── Kişisel Bakiye Kartı ──────────────────────────────
                  if (provider.myBalance != null) ...[
                    _MyBalanceCard(balance: provider.myBalance!),
                    const SizedBox(height: AppSpacing.xl),
                  ],

                  // ── Tüm Bakiyeler ─────────────────────────────────────
                  Text(
                    'Tüm Bakiyeler',
                    style: AppTextStyles.headlineSmall,
                  ),
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

/// Kişisel bakiye kartı.
class _MyBalanceCard extends StatelessWidget {
  const _MyBalanceCard({required this.balance});
  final BalanceModel balance;

  @override
  Widget build(BuildContext context) {
    final isInDebt = balance.isInDebt;

    return AppGradientCard(
      gradient: isInDebt ? AppColors.debtGradient : AppColors.creditGradient,
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
            style: AppTextStyles.amountLarge.copyWith(color: Colors.white),
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
