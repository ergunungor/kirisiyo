import 'package:flutter/foundation.dart';
import '../models/balance_model.dart';
import '../repositories/balance_repository.dart';

/// Bakiye motoru state enum'u.
enum BalanceStatus { idle, loading, success, error }

/// Bakiye motoru provider'ı.
///
/// Developer 5 (Backend & Balance Engine) bu provider'ı yönetir.
///
/// Sorumluluklar:
///   - Bakiye hesaplama
///   - Ödeme tavsiyelerini hesaplama
///   - Kişisel bakiye durumunu tutma
class BalanceProvider extends ChangeNotifier {
  BalanceProvider({IBalanceRepository? balanceRepository})
    : _balanceRepository = balanceRepository ?? const BalanceRepository();

  final IBalanceRepository _balanceRepository;

  // ── State ─────────────────────────────────────────────────────────────────

  BalanceStatus _status = BalanceStatus.idle;
  BalanceStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _status == BalanceStatus.loading;
  bool get hasError => _status == BalanceStatus.error;

  List<BalanceModel> _balances = [];
  List<BalanceModel> get balances => List.unmodifiable(_balances);

  List<SettlementModel> _settlements = [];
  List<SettlementModel> get settlements => List.unmodifiable(_settlements);

  BalanceModel? _myBalance;
  BalanceModel? get myBalance => _myBalance;

  // ── Aksiyon Metodları ────────────────────────────────────────────────────

  /// Oda bakiyelerini yükler.
  ///
  Future<void> loadBalances(String roomId) async {
    _setLoading();

    try {
      _balances = await _balanceRepository.calculateBalances(roomId);
      _setSuccess();
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Ödeme tavsiyelerini yükler.
  ///
  Future<void> loadSettlements(String roomId) async {
    _setLoading();

    try {
      _settlements = await _balanceRepository.calculateSettlements(roomId);
      _setSuccess();
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Kişisel bakiyeyi yükler.
  ///
  Future<void> loadMyBalance({
    required String roomId,
    required String memberId,
  }) async {
    _setLoading();

    try {
      _myBalance = await _balanceRepository.getMemberBalance(
        roomId: roomId,
        memberId: memberId,
      );
      _setSuccess();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> loadAll({required String roomId, String? memberId}) async {
    _setLoading();

    try {
      // Tek çağrıda hesaplayıp settlement'ları balances içinden türetiyoruz
      // (calculateSettlements'ı ayrıca çağırmak veriyi 2 kez çekmek demek olurdu).
      _balances = await _balanceRepository.calculateBalances(roomId);
      _settlements =
          _balances
              .expand((b) => b.owes)
              .map(
                (d) => SettlementModel(
                  fromMemberId: d.fromMemberId,
                  fromMemberName: d.fromMemberName,
                  toMemberId: d.toMemberId,
                  toMemberName: d.toMemberName,
                  amount: d.amount,
                ),
              )
              .toList();

      if (memberId != null) {
        _myBalance = _balances.where((b) => b.memberId == memberId).firstOrNull;
      }

      _setSuccess();
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Şu an borçlu olduğum tüm kişilere olan borcumu "ödendi" olarak
  /// işaretler (her biri için bir ödeme kaydı oluşturur) ve bakiyeleri
  /// yeniden yükler.
  Future<void> settleAllMyDebts({
    required String roomId,
    required String memberId,
  }) async {
    _setLoading();

    try {
      final myDebts = _myBalance?.owes ?? const <DebtRecord>[];
      for (final debt in myDebts) {
        await _balanceRepository.recordPayment(
          roomId: roomId,
          fromMemberId: debt.fromMemberId,
          toMemberId: debt.toMemberId,
          amount: debt.amount,
        );
      }
      await loadAll(roomId: roomId, memberId: memberId);
    } catch (e) {
      _setError(e.toString());
    }
  } // ── Private Yardımcı Metodlar ─────────────────────────────────────────────

  void _setLoading() {
    _status = BalanceStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setSuccess() {
    _status = BalanceStatus.success;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = BalanceStatus.error;
    _errorMessage = message;
    notifyListeners();
  }
}
