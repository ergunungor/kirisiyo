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
  BalanceProvider({
    IBalanceRepository? balanceRepository,
  }) : _balanceRepository = balanceRepository ?? const BalanceRepository();

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
  /// TODO [Developer 5]: [_balanceRepository.calculateBalances] çağrısı yapın.
  Future<void> loadBalances(String roomId) async {
    _setLoading();

    try {
      // TODO [Developer 5]: Repository çağrısını implement edin.
      //   _balances = await _balanceRepository.calculateBalances(roomId);
      _setSuccess();
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Ödeme tavsiyelerini yükler.
  ///
  /// TODO [Developer 5]: [_balanceRepository.calculateSettlements] çağrısı yapın.
  Future<void> loadSettlements(String roomId) async {
    _setLoading();

    try {
      // TODO [Developer 5]: Repository çağrısını implement edin.
      //   _settlements = await _balanceRepository.calculateSettlements(roomId);
      _setSuccess();
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Kişisel bakiyeyi yükler.
  ///
  /// TODO [Developer 5]: [_balanceRepository.getMemberBalance] çağrısı yapın.
  Future<void> loadMyBalance({
    required String roomId,
    required String memberId,
  }) async {
    _setLoading();

    try {
      // TODO [Developer 5]: Repository çağrısını implement edin.
      //   _myBalance = await _balanceRepository.getMemberBalance(
      //     roomId: roomId,
      //     memberId: memberId,
      //   );
      _setSuccess();
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Bakiye ve ödeme tavsiyelerini birlikte yükler.
  Future<void> loadAll({
    required String roomId,
    String? memberId,
  }) async {
    _setLoading();

    try {
      // TODO [Developer 5]: Paralel yükleme yapın.
      //   await Future.wait([
      //     loadBalances(roomId),
      //     loadSettlements(roomId),
      //     if (memberId != null) loadMyBalance(roomId: roomId, memberId: memberId),
      //   ]);
      _setSuccess();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // ── Private Yardımcı Metodlar ─────────────────────────────────────────────

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
