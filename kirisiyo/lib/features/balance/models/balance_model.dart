import 'package:equatable/equatable.dart';

/// Bakiye modeli.
///
/// Bir üyenin oda içindeki net bakiyesini temsil eder.
/// Developer 5 (Backend & Balance Engine) bu modeli yönetir.
class BalanceModel extends Equatable {
  const BalanceModel({
    required this.memberId,
    required this.memberName,
    required this.netBalance,
    this.owes = const [],
    this.isOwed = const [],
  });

  final String memberId;
  final String memberName;

  /// Pozitif = diğerleri bu kişiye borçlu
  /// Negatif = bu kişi diğerlerine borçlu
  final double netBalance;

  /// Bu kişinin borçlu olduğu kişiler
  final List<DebtRecord> owes;

  /// Bu kişiye borçlu olanlar
  final List<DebtRecord> isOwed;

  bool get isInDebt => netBalance < 0;
  bool get isInCredit => netBalance > 0;
  bool get isSettled => netBalance == 0;

  // ── Serialization ─────────────────────────────────────────────────────────

  /// Not: Bakiyeler hesaplanarak oluşturulur, doğrudan DB'den gelmez.
  factory BalanceModel.fromJson(Map<String, dynamic> json) {
    return BalanceModel(
      memberId: json['member_id'] as String,
      memberName: json['member_name'] as String,
      netBalance: (json['net_balance'] as num).toDouble(),
      owes: (json['owes'] as List<dynamic>?)
              ?.map((d) => DebtRecord.fromJson(d as Map<String, dynamic>))
              .toList() ??
          [],
      isOwed: (json['is_owed'] as List<dynamic>?)
              ?.map((d) => DebtRecord.fromJson(d as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'member_id': memberId,
      'member_name': memberName,
      'net_balance': netBalance,
      'owes': owes.map((d) => d.toJson()).toList(),
      'is_owed': isOwed.map((d) => d.toJson()).toList(),
    };
  }

  // ── Copy With ─────────────────────────────────────────────────────────────

  BalanceModel copyWith({
    String? memberId,
    String? memberName,
    double? netBalance,
    List<DebtRecord>? owes,
    List<DebtRecord>? isOwed,
  }) {
    return BalanceModel(
      memberId: memberId ?? this.memberId,
      memberName: memberName ?? this.memberName,
      netBalance: netBalance ?? this.netBalance,
      owes: owes ?? this.owes,
      isOwed: isOwed ?? this.isOwed,
    );
  }

  @override
  List<Object?> get props => [memberId, memberName, netBalance, owes, isOwed];
}

/// Borç kaydı (tek yönlü).
class DebtRecord extends Equatable {
  const DebtRecord({
    required this.fromMemberId,
    required this.fromMemberName,
    required this.toMemberId,
    required this.toMemberName,
    required this.amount,
  });

  /// Borcu ödemesi gereken kişi
  final String fromMemberId;
  final String fromMemberName;

  /// Borcun ödeneceği kişi
  final String toMemberId;
  final String toMemberName;

  final double amount;

  factory DebtRecord.fromJson(Map<String, dynamic> json) {
    return DebtRecord(
      fromMemberId: json['from_member_id'] as String,
      fromMemberName: json['from_member_name'] as String,
      toMemberId: json['to_member_id'] as String,
      toMemberName: json['to_member_name'] as String,
      amount: (json['amount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'from_member_id': fromMemberId,
      'from_member_name': fromMemberName,
      'to_member_id': toMemberId,
      'to_member_name': toMemberName,
      'amount': amount,
    };
  }

  DebtRecord copyWith({
    String? fromMemberId,
    String? fromMemberName,
    String? toMemberId,
    String? toMemberName,
    double? amount,
  }) {
    return DebtRecord(
      fromMemberId: fromMemberId ?? this.fromMemberId,
      fromMemberName: fromMemberName ?? this.fromMemberName,
      toMemberId: toMemberId ?? this.toMemberId,
      toMemberName: toMemberName ?? this.toMemberName,
      amount: amount ?? this.amount,
    );
  }

  @override
  List<Object?> get props =>
      [fromMemberId, toMemberId, amount];
}

/// Ödeme tavsiyesi modeli.
///
/// Minimum transfer sayısıyla bakiyeleri sıfırlamak için.
/// Developer 5 (Backend & Balance Engine) bu modeli yönetir.
class SettlementModel extends Equatable {
  const SettlementModel({
    required this.fromMemberId,
    required this.fromMemberName,
    required this.toMemberId,
    required this.toMemberName,
    required this.amount,
    this.isCompleted = false,
  });

  final String fromMemberId;
  final String fromMemberName;
  final String toMemberId;
  final String toMemberName;
  final double amount;
  final bool isCompleted;

  factory SettlementModel.fromJson(Map<String, dynamic> json) {
    return SettlementModel(
      fromMemberId: json['from_member_id'] as String,
      fromMemberName: json['from_member_name'] as String,
      toMemberId: json['to_member_id'] as String,
      toMemberName: json['to_member_name'] as String,
      amount: (json['amount'] as num).toDouble(),
      isCompleted: json['is_completed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'from_member_id': fromMemberId,
      'from_member_name': fromMemberName,
      'to_member_id': toMemberId,
      'to_member_name': toMemberName,
      'amount': amount,
      'is_completed': isCompleted,
    };
  }

  SettlementModel copyWith({
    String? fromMemberId,
    String? fromMemberName,
    String? toMemberId,
    String? toMemberName,
    double? amount,
    bool? isCompleted,
  }) {
    return SettlementModel(
      fromMemberId: fromMemberId ?? this.fromMemberId,
      fromMemberName: fromMemberName ?? this.fromMemberName,
      toMemberId: toMemberId ?? this.toMemberId,
      toMemberName: toMemberName ?? this.toMemberName,
      amount: amount ?? this.amount,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props =>
      [fromMemberId, toMemberId, amount, isCompleted];
}
