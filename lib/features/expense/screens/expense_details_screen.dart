import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/app_colors.dart';
import '../../../app/app_spacing.dart';
import '../../../app/app_text_styles.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/state_widgets.dart';
import '../../../core/utils/formatters.dart';
import '../providers/expense_provider.dart';
import '../../room/providers/room_provider.dart';

/// Harcama detay ekranı.
///
/// Developer 3 (Expense Management) bu ekranı yönetir.
///
/// Gösterilenler:
///   - Harcama başlığı, miktarı
///   - Ödeyeni
///   - Katılımcılar ve pay miktarları
///   - Tarih
///   - Fiş fotoğrafı (varsa)
///
/// TODO [Developer 3]: Gerçek veriyi provider üzerinden yükleyin.
class ExpenseDetailsScreen extends StatefulWidget {
  const ExpenseDetailsScreen({
    super.key,
    required this.roomCode,
    required this.expenseId,
  });

  final String roomCode;
  final String expenseId;

  @override
  State<ExpenseDetailsScreen> createState() => _ExpenseDetailsScreenState();
}

class _ExpenseDetailsScreenState extends State<ExpenseDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // TODO [Developer 3]: Harcamayı yükleyin.
    context.read<ExpenseProvider>().loadExpenseById(widget.expenseId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Harcama Detayı'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
          child: Consumer<ExpenseProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const LoadingWidget(message: 'Harcama yükleniyor...');
              }

              final expense = provider.selectedExpense;

              if (expense == null || provider.hasError) {
                return ErrorStateWidget(
                  message: provider.errorMessage ?? 'Harcama yüklenemedi.',
                  onRetry: () {
                    // TODO [Developer 3]: Tekrar yükle
                  },
                );
              }

              return ListView(
                padding: AppSpacing.paddingPage,
                children: [
                  // ── Başlık ve Miktar ──────────────────────────────────
                  Center(
                    child: Text(
                      expense.emoji ?? '💰',
                      style: const TextStyle(fontSize: 64),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    expense.title,
                    style: AppTextStyles.displayMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    CurrencyFormatter.format(expense.amount),
                    style: AppTextStyles.amountLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    DateFormatter.formatLong(expense.date),
                    style: AppTextStyles.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // ── Bölüştürme Detayları ──────────────────────────────
                  Text(
                    'Bölüştürme',
                    style: AppTextStyles.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (expense.splits.isEmpty)
                    Text(
                      'Bölüştürme bilgisi bulunamadı.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    )
                  else
                    ...expense.splits.map((split) {
                      final member = context
                          .watch<RoomProvider>()
                          .currentRoom
                          ?.members
                          .where((m) => m.id == split.memberId)
                          .firstOrNull;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                member?.name ?? 'Bilinmeyen Kullanıcı',
                                style: AppTextStyles.bodyMedium,
                              ),
                            ),
                            Text(
                              CurrencyFormatter.format(split.amount),
                              style: AppTextStyles.bodyMedium,
                            ),
                          ],
                        ),
                      );
                    }),

                  // ── Fiş Fotoğrafı ─────────────────────────────────────
                  if (expense.photoUrl != null) ...[
                    const SizedBox(height: AppSpacing.xl),
                    Text('Fiş', style: AppTextStyles.headlineSmall),
                    const SizedBox(height: AppSpacing.md),
                    // TODO [Developer 3]: CachedNetworkImage ile fotoğrafı göster.
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      child: Image.network(
                        expense.photoUrl!,
                        fit: BoxFit.cover,
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
