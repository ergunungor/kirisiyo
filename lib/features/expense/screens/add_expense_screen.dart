import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../app/app_colors.dart';
import '../../../app/app_spacing.dart';
import '../../../app/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_card.dart';
import '../models/expense_model.dart';
import '../providers/expense_provider.dart';
import '../../room/providers/room_provider.dart';
import '../../room/models/room_model.dart';
import 'package:uuid/uuid.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

import '../../../shared/widgets/shared_widgets.dart';

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
  // --- Developer 3: Bölüşüm Mantığı Değişkenleri ---
  List<String> _selectedMemberIds = [];
  SplitType _splitType = SplitType.equal;
  Map<String, double> _customSplits = {};

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // Tutar girildiğinde veya kişi seçildiğinde eşit bölüşümü hesaplayan fonksiyon
  void _calculateEqualSplit() {
    if (_selectedMemberIds.isEmpty) return;

    // Girilen tutarı al (virgülü noktaya çevir ki matematiksel hata vermesin)
    final amountText = _amountController.text.replaceAll(',', '.');
    final double totalAmount = double.tryParse(amountText) ?? 0.0;

    if (totalAmount <= 0) return;

    // Toplam tutarı seçili kişi sayısına eşit olarak böl
    final double splitAmount = totalAmount / _selectedMemberIds.length;

    // Ekranı güncelle ve herkesin payını _customSplits listesine yaz
    setState(() {
      _customSplits.clear(); // Önceki hesaplamayı temizle
      for (var memberId in _selectedMemberIds) {
        _customSplits[memberId] = splitAmount;
      }
    });
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
          constraints: const BoxConstraints(
            maxWidth: AppSpacing.maxContentWidth,
          ),
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
                      validator:
                          (v) =>
                              v == null || v.trim().isEmpty
                                  ? 'Başlık boş bırakılamaz.'
                                  : null,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // ── Tarih ─────────────────────────────────────────────
                    _buildDatePicker(context),
                    const SizedBox(height: AppSpacing.md),

                    // ── Ödeyeni seç ───────────────────────────────────────
                    if (room != null) _buildPaidBySelector(room.members),
                    const SizedBox(height: AppSpacing.md),

                    // ── Emoji seç ─────────────────────────────────────────
                    _buildEmojiSelector(),
                    const SizedBox(height: AppSpacing.md),

                    // ── Bölüştürme ────────────────────────────────────────
                    _buildSplitSection(
                      context,
                      expenseProvider,
                      room?.members ?? [],
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // ── Kaydet ────────────────────────────────────────────
                    AppButton(
                      label: 'Harcamayı Kaydet',
                      onPressed:
                          expenseProvider.isLoading
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
          const Icon(
            Icons.calendar_today_rounded,
            color: AppColors.textSecondary,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            DateFormatter.formatLong(_selectedDate),
            style: AppTextStyles.bodyMedium,
          ),
          const Spacer(),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: AppColors.textSecondary,
          ),
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
          height: 56,
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
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? AppColors.primary.withOpacity(0.2)
                            : AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.divider,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MemberAvatar(name: member.name, size: AvatarSize.small),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        member.name,
                        style: AppTextStyles.labelMedium.copyWith(
                          color:
                              isSelected
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                        ),
                      ),
                    ],
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
    return AppCard(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return SizedBox(
              height: 280,
              child: EmojiPicker(
                onEmojiSelected: (category, emoji) {
                  setState(() {
                    _selectedEmoji = emoji.emoji;
                  });
                  Navigator.of(context).pop();
                },
              ),
            );
          },
        );
      },
      child: Row(
        children: [
          Text(_selectedEmoji ?? '😊', style: const TextStyle(fontSize: 28)),
          const SizedBox(width: AppSpacing.md),
          Text(
            _selectedEmoji != null ? 'Emoji seçildi' : 'Emoji Seç',
            style: AppTextStyles.bodyMedium,
          ),
          const Spacer(),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textSecondary,
          ),
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
          onSelectionChanged: (s) {
            provider.setSplitType(s.first);
            setState(() => _splitType = s.first);
          },
        ),
        const SizedBox(height: AppSpacing.md),
        if (members.isNotEmpty)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                final allSelected = members.every(
                  (m) => _selectedMemberIds.contains(m.id),
                );
                setState(() {
                  if (allSelected) {
                    _selectedMemberIds.clear();
                    _customSplits.clear();
                  } else {
                    _selectedMemberIds = members.map((m) => m.id).toList();
                  }
                  if (_splitType == SplitType.equal) {
                    _calculateEqualSplit();
                  }
                });
              },
              icon: Icon(
                members.every((m) => _selectedMemberIds.contains(m.id))
                    ? Icons.remove_done_rounded
                    : Icons.done_all_rounded,
                size: 18,
              ),
              label: Text(
                members.every((m) => _selectedMemberIds.contains(m.id))
                    ? 'Seçimi Kaldır'
                    : 'Hepsini Seç',
              ),
            ),
          ),
        // --- Developer 3: Katılımcı Seçimi (Adım 6) ---
        // --- Developer 3: Katılımcı Seçimi ve Özel Tutar Girişi (Adım 6 & 8) ---
        Column(
          children:
              members.map((member) {
                final isSelected = _selectedMemberIds.contains(member.id);

                return Column(
                  children: [
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(member.name ?? 'Bilinmeyen Kullanıcı'),
                      value: isSelected,
                      activeColor: AppColors.primary,
                      onChanged: (bool? checked) {
                        setState(() {
                          if (checked == true) {
                            _selectedMemberIds.add(member.id);
                          } else {
                            _selectedMemberIds.remove(member.id);
                            _customSplits.remove(
                              member.id,
                            ); // Kişi listeden çıkarsa borcunu da sıfırla
                          }

                          // Eğer eşit bölüşümdeysek, kişi sayısı değiştiği için hesabı güncelle
                          if (_splitType == SplitType.equal) {
                            _calculateEqualSplit();
                          }
                        });
                      },
                    ),
                    // Sadece "Özel" (Custom) bölüşüm seçiliyse ve kişi işaretliyse tutar kutucuğunu göster
                    if (_splitType == SplitType.custom && isSelected)
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 48.0,
                          right: 16.0,
                          bottom: 8.0,
                        ),
                        child: TextFormField(
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Ödeyeceği Tutar',
                            prefixText: '₺ ',
                          ),
                          initialValue:
                              _customSplits[member.id]?.toString() ?? '',
                          onChanged: (value) {
                            // Girilen virgüllü sayıyı noktaya çevirip arka plandaki listeye kaydet
                            final parsedValue =
                                double.tryParse(value.replaceAll(',', '.')) ??
                                0.0;
                            setState(() {
                              _customSplits[member.id] = parsedValue;
                            });
                          },
                        ),
                      ),
                  ],
                );
              }).toList(),
        ),
      ],
    );
  }

  Future<void> _saveExpense(
    BuildContext context,
    ExpenseProvider provider,
  ) async {
    if (!_formKey.currentState!.validate()) return;
    if (_splitType == SplitType.custom) {
      final totalAmount =
          double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0.0;
      final splitSum = _customSplits.values.fold(0.0, (a, b) => a + b);
      if ((totalAmount - splitSum).abs() > 0.01) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 2),
            content: Text(
              'Bölüştürme toplamı (${CurrencyFormatter.format(splitSum)}) '
              'harcama tutarına (${CurrencyFormatter.format(totalAmount)}) eşit değil.',
            ),
          ),
        );
        return;
      }
    }

    if (_paidByMemberId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: const Duration(seconds: 2),
          content: Text('Lütfen ödeyeni seçin.'),
        ),
      );
      return;
    }

    // Provider'ları ve aktif odayı context üzerinden buluyoruz
    final expenseProvider = context.read<ExpenseProvider>();
    final roomProvider = context.read<RoomProvider>();
    final roomId = roomProvider.currentRoom?.id ?? '';

    if (roomId.isEmpty) return; // Hata durumunda kaydetmeyi durdur

    // Harcama için ortak bir benzersiz ID oluşturalım
    final String generatedExpenseId = const Uuid().v4();

    // Kendi hesapladığımız verilerle harcama modelini oluşturuyoruz
    final expense = ExpenseModel(
      id: generatedExpenseId, // Ürettiğimiz ID'yi buraya veriyoruz
      roomId: roomId,
      title: _titleController.text.trim(),
      amount: double.parse(_amountController.text.replaceAll(',', '.')),
      paidByMemberId: _paidByMemberId!,
      date: _selectedDate,
      createdAt: DateTime.now(),
      emoji: _selectedEmoji,
      splitType: _splitType,
      splits:
          _customSplits.entries
              .map(
                (entry) => ExpenseSplitModel(
                  id: const Uuid().v4(), // Her bir pay/borç için benzersiz ID
                  expenseId:
                      generatedExpenseId, // Bu payın yukarıdaki harcamaya ait olduğunu belirtiyoruz
                  memberId: entry.key,
                  amount: entry.value,
                ),
              )
              .toList(),
    );

    // Veritabanına (Supabase) yolla
    try {
      // 1. Supabase'e yolla
      await expenseProvider.createExpense(expense);

      // 2. İşlem başarılıysa sayfayı kapat
      if (context.mounted) {
        context.pop();
      }
    } catch (e) {
      // 3. Patlarsa ekranda kırmızı çizgi verme, hatayı direkt konsola yazdır!
      print('🔥 SUPABASE HATASI PATLADI KANKA: $e');
    }
  }
}
