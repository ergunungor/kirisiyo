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
import '../../../core/utils/formatters.dart';
import '../models/expense_model.dart';
import '../providers/expense_provider.dart';
import '../../room/providers/room_provider.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({
    super.key,
    required this.roomCode,
    this.embedded = false,
  });

  final String roomCode;

  /// true ise (RoomDetailScreen'de sekme olarak gömülüyken) kendi
  /// Scaffold/AppBar'ını göstermez — dıştaki appbar'la çakışmasın diye.
  final bool embedded;
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
    final content = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
        child: Consumer<ExpenseProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const LoadingWidget(message: 'Harcamalar yükleniyor...');
            }

            if (provider.hasError) {
              return ErrorStateWidget(
                message: provider.errorMessage ?? 'Harcamalar yüklenemedi.',
                onRetry: () {
                  final roomId = context.read<RoomProvider>().currentRoom?.id;
                  if (roomId != null) {
                    provider.loadExpenses(roomId);
                  }
                },
              );
            }

            if (provider.expenses.isEmpty) {
              return const EmptyStateWidget(
                title: 'Harcama Yok',
                description: 'Henüz harcama eklenmemiş. İlk harcamayı ekleyin!',
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
                  return Dismissible(
                    key: Key(expense.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.debtRed,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.white,
                      ),
                    ),
                    onDismissed: (_) async {
                      print('SILME TETIKLENDI: ${expense.id}');
                      try {
                        await context
                            .read<ExpenseProvider>()
                            .deleteExpense(expense.id);
                        print('SILME BASARILI');
                      } catch (e) {
                        print('SILME HATASI: $e');
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Silinemedi: $e')),
                          );
                        }
                      }
                    },
                    child: _ExpenseListTile(
                      expense: expense,
                      onTap:
                          () => context.push(
                            AppRoutes.expenseDetailsPath(
                              widget.roomCode,
                              expense.id,
                            ),
                          ),
                    ),
                  );
                },
            );
          },
        ),
      ),
    );

    if (widget.embedded) return content;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(title: const Text('Harcamalar')),
      body: content,
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
              final payer =
                  roomProvider.currentRoom?.members
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
