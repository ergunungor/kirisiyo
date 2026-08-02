import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../app/app_colors.dart';
import '../../../app/app_spacing.dart';
import '../../../app/app_text_styles.dart';
import '../../../app/router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_card.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../models/expense_model.dart';
import '../providers/expense_provider.dart';
import '../../room/providers/room_provider.dart';
import '../../room/models/room_model.dart';

/// Harcama ekleme ekranı.
///
/// Developer 3 (Expense Management) bu ekranı yönetir.
///
/// Alanlar:
///   - Başlık (required)
///   - Miktar (required)
///   - Tarih (required)
///   - Ödeyeni (required)
///   - Emoji veya fotoğraf (optional)
///   - Katılımcı seçimi + split tipi
///
/// TODO [Developer 3]: Form validasyonu ve provider bağlantısını tamamlayın.
class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key, required this.roomCode});

  final String roomCode;

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? _selectedEmoji;
  String? _paidByMemberId;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Harcama Ekle'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.close_rounded),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
          child: Consumer2<ExpenseProvider, RoomProvider>(
            builder: (context, expenseProvider, roomProvider, _) {
              final room = roomProvider.currentRoom;

              return Form(
                key: _formKey,
                child: ListView(
                  padding: AppSpacing.paddingPage,
                  children: [
                    // ── Miktar (en üstte büyük gösterim) ──────────────────
                    _buildAmountSection(),
                    const Divider(height: AppSpacing.xl),

                    // ── Başlık ────────────────────────────────────────────
                    AppTextField(
                      label: 'Başlık',
                      hint: 'Örn: Akşam yemeği, Taksi',
                      controller: _titleController,
                      prefixIcon: Icons.title_rounded,
                      maxLength: AppConstants.expenseTitleMaxLength,
                      textCapitalization: TextCapitalization.sentences,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Başlık boş bırakılamaz.'
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // ── Tarih ─────────────────────────────────────────────
                    _buildDatePicker(context),
                    const SizedBox(height: AppSpacing.md),

                    // ── Ödeyeni seç ───────────────────────────────────────
                    if (room != null)
                      _buildPaidBySelector(room.members),
                    const SizedBox(height: AppSpacing.md),

                    // ── Emoji seç ─────────────────────────────────────────
                    _buildEmojiSelector(),
                    const SizedBox(height: AppSpacing.md),

                    // ── Fiş tarama kısayolu ───────────────────────────────
                    _buildScanReceiptShortcut(context),
                    const SizedBox(height: AppSpacing.xl),

                    // ── Bölüştürme ────────────────────────────────────────
                    _buildSplitSection(context, expenseProvider, room?.members ?? []),
                    const SizedBox(height: AppSpacing.xxl),

                    // ── Kaydet ────────────────────────────────────────────
                    AppButton(
                      label: 'Harcamayı Kaydet',
                      onPressed: expenseProvider.isLoading
                          ? null
                          : () => _saveExpense(context, expenseProvider),
                      isLoading: expenseProvider.isLoading,
                      icon: Icons.save_rounded,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAmountSection() {
    return AppAmountTextField(
      controller: _amountController,
      autofocus: true,
      validator: (v) {
        if (v == null || v.isEmpty) return 'Miktar boş bırakılamaz.';
        final n = double.tryParse(v.replaceAll(',', '.'));
        if (n == null || n <= 0) return 'Geçerli bir miktar girin.';
        return null;
      },
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return AppCard(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          locale: const Locale('tr', 'TR'),
        );
        if (date != null) setState(() => _selectedDate = date);
      },
      child: Row(
        children: [
          const Icon(Icons.calendar_today_rounded,
              color: AppColors.textSecondary, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Text(
            DateFormatter.formatLong(_selectedDate),
            style: AppTextStyles.bodyMedium,
          ),
          const Spacer(),
          const Icon(Icons.arrow_forward_ios_rounded,
              size: 14, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildPaidBySelector(List<MemberModel> members) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Kim Ödedi?', style: AppTextStyles.labelMedium),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 60,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: members.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              final member = members[index];
              final isSelected = _paidByMemberId == member.id;
              return GestureDetector(
                onTap: () => setState(() => _paidByMemberId = member.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.2)
                        : AppColors.surface,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusRound),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.divider,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    member.name,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmojiSelector() {
    // TODO [Developer 3]: emoji_picker_flutter paketi ile emoji seçici ekleyin.
    return AppCard(
      onTap: () {
        // TODO [Developer 3]: Emoji picker bottom sheet aç.
      },
      child: Row(
        children: [
          Text(
            _selectedEmoji ?? '😊',
            style: const TextStyle(fontSize: 28),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            _selectedEmoji != null ? 'Emoji seçildi' : 'Emoji Seç',
            style: AppTextStyles.bodyMedium,
          ),
          const Spacer(),
          const Icon(Icons.chevron_right_rounded,
              color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildScanReceiptShortcut(BuildContext context) {
    return AppCard(
      onTap: () =>
          context.push(AppRoutes.receiptScannerPath(widget.roomCode)),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: const Icon(
              Icons.document_scanner_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Fiş Tara', style: AppTextStyles.labelMedium),
                Text(
                  'Kamera veya galeriden fiş yükle',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildSplitSection(
    BuildContext context,
    ExpenseProvider provider,
    List<MemberModel> members,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Bölüştürme', style: AppTextStyles.headlineSmall),
        const SizedBox(height: AppSpacing.sm),
        // Split tipi seçici
        SegmentedButton<SplitType>(
          segments: const [
            ButtonSegment(
              value: SplitType.equal,
              label: Text('Eşit'),
              icon: Icon(Icons.balance_rounded),
            ),
            ButtonSegment(
              value: SplitType.custom,
              label: Text('Özel'),
              icon: Icon(Icons.tune_rounded),
            ),
          ],
          selected: {provider.splitType},
          onSelectionChanged: (s) => provider.setSplitType(s.first),
        ),
        const SizedBox(height: AppSpacing.md),
        // TODO [Developer 3]: Katılımcı seçimi ve özel tutar girişini implement edin.
        Text(
          'TODO [Developer 3]: Katılımcı seçim ve bölüştürme UI\'ını implement edin.',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.warning,
          ),
        ),
      ],
    );
  }

  Future<void> _saveExpense(
      BuildContext context, ExpenseProvider provider) async {
    if (!_formKey.currentState!.validate()) return;

    if (_paidByMemberId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen ödeyeni seçin.')),
      );
      return;
    }

    // TODO [Developer 3]: ExpenseModel oluşturup provider.createExpense() çağırın.
    //   final expense = ExpenseModel(
    //     id: const Uuid().v4(),
    //     roomId: roomId,
    //     title: _titleController.text.trim(),
    //     amount: double.parse(_amountController.text.replaceAll(',', '.')),
    //     paidByMemberId: _paidByMemberId!,
    //     date: _selectedDate,
    //     createdAt: DateTime.now(),
    //     emoji: _selectedEmoji,
    //     splitType: provider.splitType,
    //   );
    //   await provider.createExpense(expense);

    if (!provider.hasError && context.mounted) {
      context.pop();
    }
  }
}
