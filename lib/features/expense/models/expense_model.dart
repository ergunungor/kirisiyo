import 'package:equatable/equatable.dart';

/// Harcama split tipi.
enum SplitType {
  /// Eşit bölüştürme
  equal,

  /// Özel miktar bölüştürme
  custom,
}

/// Harcama modeli.
///
/// Supabase [expenses] tablosuyla eşleşir.
/// Developer 3 (Expense Management) bu modeli yönetir.
class ExpenseModel extends Equatable {
  const ExpenseModel({
    required this.id,
    required this.roomId,
    required this.title,
    required this.amount,
    required this.paidByMemberId,
    required this.date,
    required this.createdAt,
    this.emoji,
    this.photoUrl,
    this.splitType = SplitType.equal,
    this.splits = const [],
    this.isFromReceipt = false,
  });

  final String id;
  final String roomId;
  final String title;

  /// Toplam harcama miktarı (TL)
  final double amount;

  /// Harcamayı ödeyen üye ID'si
  final String paidByMemberId;

  final DateTime date;
  final DateTime createdAt;

  /// Harcama emojisi (isteğe bağlı)
  final String? emoji;

  /// Fiş/makbuz fotoğrafı URL'i (isteğe bağlı)
  final String? photoUrl;

  final SplitType splitType;

  /// Harcama bölüştürme detayları
  final List<ExpenseSplitModel> splits;

  /// Fiş taramasından mı oluşturuldu?
  final bool isFromReceipt;

  // ── Serialization ─────────────────────────────────────────────────────────

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] as String,
      roomId: json['room_id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      paidByMemberId: json['paid_by_member_id'] as String,
      date: DateTime.parse(json['expense_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      emoji: json['emoji'] as String?,
      photoUrl: json['image_url'] as String?,
      splitType: SplitType.values.firstWhere(
        (e) => e.name == (json['split_type'] as String? ?? 'equal'),
        orElse: () => SplitType.equal,
      ),
      splits:
          (json['expense_splits'] as List<dynamic>?)
              ?.map(
                (s) => ExpenseSplitModel.fromJson(s as Map<String, dynamic>),
              )
              .toList() ??
          [],
      isFromReceipt: json['is_from_receipt'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_id': roomId,
      'title': title,
      'amount': amount,
      'paid_by_member_id': paidByMemberId,
      'expense_date': date.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'emoji': emoji,
      'image_url': photoUrl,
      'split_type': splitType.name,
      'is_from_receipt': isFromReceipt,
    };
  }

  // ── Copy With ─────────────────────────────────────────────────────────────

  ExpenseModel copyWith({
    String? id,
    String? roomId,
    String? title,
    double? amount,
    String? paidByMemberId,
    DateTime? date,
    DateTime? createdAt,
    String? emoji,
    String? photoUrl,
    SplitType? splitType,
    List<ExpenseSplitModel>? splits,
    bool? isFromReceipt,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      paidByMemberId: paidByMemberId ?? this.paidByMemberId,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      emoji: emoji ?? this.emoji,
      photoUrl: photoUrl ?? this.photoUrl,
      splitType: splitType ?? this.splitType,
      splits: splits ?? this.splits,
      isFromReceipt: isFromReceipt ?? this.isFromReceipt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    roomId,
    title,
    amount,
    paidByMemberId,
    date,
    createdAt,
    emoji,
    photoUrl,
    splitType,
    splits,
    isFromReceipt,
  ];

  @override
  String toString() =>
      'ExpenseModel(title: $title, amount: $amount, paidBy: $paidByMemberId)';
}

/// Harcama bölüştürme modeli.
///
/// Supabase [expense_splits] tablosuyla eşleşir.
/// Developer 3 (Expense Management) bu modeli yönetir.
class ExpenseSplitModel extends Equatable {
  const ExpenseSplitModel({
    required this.id,
    required this.expenseId,
    required this.memberId,
    required this.amount,
    this.isPaid = false,
  });

  final String id;
  final String expenseId;
  final String memberId;

  /// Bu üyenin ödemesi gereken miktar
  final double amount;

  /// Ödeme yapıldı mı?
  final bool isPaid;

  // ── Serialization ─────────────────────────────────────────────────────────

  factory ExpenseSplitModel.fromJson(Map<String, dynamic> json) {
    return ExpenseSplitModel(
      id: json['id'] as String,
      expenseId: json['expense_id'] as String,
      memberId: json['member_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      isPaid: json['is_paid'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'expense_id': expenseId,
      'member_id': memberId,
      'amount': amount,
      'is_paid': isPaid,
    };
  }

  // ── Copy With ─────────────────────────────────────────────────────────────

  ExpenseSplitModel copyWith({
    String? id,
    String? expenseId,
    String? memberId,
    double? amount,
    bool? isPaid,
  }) {
    return ExpenseSplitModel(
      id: id ?? this.id,
      expenseId: expenseId ?? this.expenseId,
      memberId: memberId ?? this.memberId,
      amount: amount ?? this.amount,
      isPaid: isPaid ?? this.isPaid,
    );
  }

  @override
  List<Object?> get props => [id, expenseId, memberId, amount, isPaid];
}
