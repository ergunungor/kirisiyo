import '../../room/models/room_model.dart';
import '../../../core/services/base_repository.dart';
import '../models/balance_model.dart';

/// Bakiye repository arayüzü.
///
/// Developer 5 (Backend & Balance Engine) bu arayüzü implemente eder.
abstract interface class IBalanceRepository {
  /// Bir oda için tüm üyelerin bakiyelerini hesaplar.
  Future<List<BalanceModel>> calculateBalances(String roomId);

  /// Minimum transfer sayısıyla ödeme tavsiyelerini hesaplar.
  Future<List<SettlementModel>> calculateSettlements(String roomId);

  /// Belirli bir üyenin net bakiyesini döner.
  Future<BalanceModel> getMemberBalance({
    required String roomId,
    required String memberId,
  });

  /// Gerçekleşen bir ödemeyi kaydeder (borç kapatma).
  Future<void> recordPayment({
    required String roomId,
    required String fromMemberId,
    required String toMemberId,
    required double amount,
  });
}

/// Bakiye repository implementasyonu.
///
/// Net bakiyeleri Supabase'deki [v_member_paid] ve [v_member_share]
/// view'larından okur, kayıtlı [settlements] ödemelerini bu net
/// bakiyeye uygular, ödeme tavsiyelerini ise "Simplify Debts"
/// algoritmasıyla üretir.
base class BalanceRepository extends BaseRepository
    implements IBalanceRepository {
  const BalanceRepository();

  static const _membersTable = 'room_members';
  static const _paidView = 'v_member_paid';
  static const _shareView = 'v_member_share';
  static const _settlementsTable = 'settlements';

  /// Odanın üyelerini ve her üyenin net bakiyesini
  /// (ödediği toplam - payına düşen toplam, kayıtlı ödemeler uygulanmış)
  /// hesaplar.
  Future<(List<MemberModel>, Map<String, double>)> _loadNetBalances(
    String roomId,
  ) async {
    try {
      final membersResponse = await client
          .from(_membersTable)
          .select()
          .eq('room_id', roomId);

      final members =
          (membersResponse as List)
              .map((m) => MemberModel.fromJson(m as Map<String, dynamic>))
              .toList();

      final paidResponse = await client
          .from(_paidView)
          .select()
          .eq('room_id', roomId);
      final paidMap = <String, double>{
        for (final row in (paidResponse as List))
          row['member_id'] as String: (row['total_paid'] as num).toDouble(),
      };

      final shareResponse = await client
          .from(_shareView)
          .select()
          .eq('room_id', roomId);
      final shareMap = <String, double>{
        for (final row in (shareResponse as List))
          row['member_id'] as String: (row['total_share'] as num).toDouble(),
      };

      final netBalances = <String, double>{
        for (final member in members)
          member.id: (paidMap[member.id] ?? 0) - (shareMap[member.id] ?? 0),
      };

      // Kayıtlı ödemeleri uygula: ödeyen kişinin bakiyesi 0'a yaklaşır,
      // ödemeyi alan kişinin alacağı o kadar azalır.
      final settlementsResponse = await client
          .from(_settlementsTable)
          .select()
          .eq('room_id', roomId);

      for (final row in (settlementsResponse as List)) {
        final from = row['from_member_id'] as String;
        final to = row['to_member_id'] as String;
        final amount = (row['amount'] as num).toDouble();
        netBalances[from] = (netBalances[from] ?? 0) + amount;
        netBalances[to] = (netBalances[to] ?? 0) - amount;
      }

      return (members, netBalances);
    } on RepositoryException {
      rethrow;
    } catch (e) {
      throw BackendException('Bakiye verileri okunamadı: $e');
    }
  }

  /// "Simplify Debts" (borç sadeleştirme) algoritması.
  ///
  /// Greedy yaklaşım: en büyük alacaklıyla en büyük borçluyu eşleştir,
  /// bu minimum transfer sayısına yakın bir sonuç verir.
  List<SettlementModel> _simplifyDebts(
    List<MemberModel> members,
    Map<String, double> netBalances,
  ) {
    const epsilon = 0.01;

    final creditors = <MapEntry<MemberModel, double>>[];
    final debtors = <MapEntry<MemberModel, double>>[];

    for (final member in members) {
      final net = netBalances[member.id] ?? 0;
      if (net > epsilon) {
        creditors.add(MapEntry(member, net));
      } else if (net < -epsilon) {
        debtors.add(MapEntry(member, -net));
      }
    }

    creditors.sort((a, b) => b.value.compareTo(a.value));
    debtors.sort((a, b) => b.value.compareTo(a.value));

    final settlements = <SettlementModel>[];
    var i = 0, j = 0;

    while (i < debtors.length && j < creditors.length) {
      final debtor = debtors[i];
      final creditor = creditors[j];
      final amount =
          debtor.value < creditor.value ? debtor.value : creditor.value;

      if (amount > epsilon) {
        settlements.add(
          SettlementModel(
            fromMemberId: debtor.key.id,
            fromMemberName: debtor.key.name,
            toMemberId: creditor.key.id,
            toMemberName: creditor.key.name,
            amount: double.parse(amount.toStringAsFixed(2)),
          ),
        );
      }

      debtors[i] = MapEntry(debtor.key, debtor.value - amount);
      creditors[j] = MapEntry(creditor.key, creditor.value - amount);

      if (debtors[i].value <= epsilon) i++;
      if (creditors[j].value <= epsilon) j++;
    }

    return settlements;
  }

  @override
  Future<List<BalanceModel>> calculateBalances(String roomId) async {
    final (members, netBalances) = await _loadNetBalances(roomId);
    final settlements = _simplifyDebts(members, netBalances);

    final debtRecords =
        settlements
            .map(
              (s) => DebtRecord(
                fromMemberId: s.fromMemberId,
                fromMemberName: s.fromMemberName,
                toMemberId: s.toMemberId,
                toMemberName: s.toMemberName,
                amount: s.amount,
              ),
            )
            .toList();

    return members.map((member) {
      return BalanceModel(
        memberId: member.id,
        memberName: member.name,
        netBalance: netBalances[member.id] ?? 0,
        owes: debtRecords.where((d) => d.fromMemberId == member.id).toList(),
        isOwed: debtRecords.where((d) => d.toMemberId == member.id).toList(),
      );
    }).toList();
  }

  @override
  Future<List<SettlementModel>> calculateSettlements(String roomId) async {
    final (members, netBalances) = await _loadNetBalances(roomId);
    return _simplifyDebts(members, netBalances);
  }

  @override
  Future<BalanceModel> getMemberBalance({
    required String roomId,
    required String memberId,
  }) async {
    final balances = await calculateBalances(roomId);
    return balances.firstWhere(
      (b) => b.memberId == memberId,
      orElse: () => throw const NotFoundException('Üye bakiyesi bulunamadı.'),
    );
  }

  @override
  Future<void> recordPayment({
    required String roomId,
    required String fromMemberId,
    required String toMemberId,
    required double amount,
  }) async {
    try {
      await client.from(_settlementsTable).insert({
        'room_id': roomId,
        'from_member_id': fromMemberId,
        'to_member_id': toMemberId,
        'amount': amount,
      });
    } on RepositoryException {
      rethrow;
    } catch (e) {
      throw BackendException('Ödeme kaydedilirken bir hata oluştu: $e');
    }
  }
}
