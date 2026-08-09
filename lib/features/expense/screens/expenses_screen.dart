import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../app/app_colors.dart';
import '../../../app/app_spacing.dart';
import '../../../app/app_text_styles.dart';
import '../../../app/router.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/state_widgets.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../../../core/utils/formatters.dart';
import '../models/expense_model.dart';
import '../providers/expense_provider.dart';
import '../../room/providers/room_provider.dart';
import '../../room/providers/room_provider.dart';

/// Harcamalar listesi ekranı.
///
/// Developer 3 (Expense Management) bu ekranı yönetir.
///
/// TODO [Developer 3]: Gerçek veriyi provider üzerinden yükleyin.
class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key, required this.roomCode});

  final String roomCode;

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final roomId = context.read<RoomProvider>().currentRoom?.id;
      if (roomId != null) {
        context.read<ExpenseProvider>().loadExpenses(roomId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(title: const Text('Harcamalar')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppSpacing.maxContentWidth,
          ),
          child: Consumer<ExpenseProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const LoadingWidget(message: 'Harcamalar yükleniyor...');
              }

              if (provider.hasError) {
                return ErrorStateWidget(
                  message: provider.errorMessage ?? 'Harcamalar yüklenemedi.',
                  onRetry: () {
                    // TODO [Developer 3]: loadExpenses() çağırın
                  },
                );
              }

              if (provider.expenses.isEmpty) {
                return const EmptyStateWidget(
                  title: 'Harcama Yok',
                  description:
                      'Henüz harcama eklenmemiş. İlk harcamayı ekleyin!',
                  icon: Icons.receipt_long_rounded,
                );
              }

              return ListView.separated(
                padding: AppSpacing.paddingPage,
                itemCount: provider.expenses.length,
                separatorBuilder:
                    (_, __) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final expense = provider.expenses[index];
                  return _ExpenseListTile(
                    expense: expense,
                    onTap:
                        () => context.push(
                          AppRoutes.expenseDetailsPath(
                            widget.roomCode,
                            expense.id,
                          ),
                        ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ExpenseListTile extends StatelessWidget {
  const _ExpenseListTile({required this.expense, required this.onTap});

  final ExpenseModel expense;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          // Emoji veya fotoğraf
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Center(
              child: Text(
                expense.emoji ?? '💰',
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(expense.title, style: AppTextStyles.labelLarge),
                const SizedBox(height: 2),
                Text(
                  DateFormatter.formatSmart(expense.date),
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          Consumer<RoomProvider>(
            builder: (context, roomProvider, _) {
              final payer = roomProvider.currentRoom?.members
                  .where((m) => m.id == expense.paidByMemberId)
                  .firstOrNull;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyFormatter.format(expense.amount),
                    style: AppTextStyles.amountMedium,
                  ),
                  Text(
                    payer?.name ?? 'Bilinmeyen',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
