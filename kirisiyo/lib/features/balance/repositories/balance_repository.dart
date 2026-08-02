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
}

/// Bakiye repository implementasyonu.
///
/// TODO [Developer 5]: Bakiye hesaplama algoritmalarını implement edin.
///
/// Önerilen yaklaşım:
///   1. Oda harcamalarını getir (expense_repository kullan)
///   2. Harcama bölüştürmelerini al
///   3. Her üye için net bakiye hesapla:
///      net = (ödediği harcamalar toplamı) - (payına düşen harcamalar toplamı)
///   4. Settlement için "Simplify Debts" algoritmasını uygula
///      (minimum transfer problemi - greedy veya flow-based)
///
/// Referans algoritma: https://medium.com/@mithunmk93/algorithm-behind-splitwises-debt-simplification-feature-8ac485e97688
class BalanceRepository implements IBalanceRepository {
  const BalanceRepository();

  @override
  Future<List<BalanceModel>> calculateBalances(String roomId) async {
    // TODO [Developer 5]: Uygulama adımları:
    //   1. Oda üyelerini getir
    //   2. Tüm harcamaları ve bölüştürmeleri getir
    //   3. Her üye için:
    //      - paid = SUM(amount) WHERE paid_by_member_id = memberId
    //      - owed = SUM(split.amount) WHERE split.member_id = memberId
    //      - net = paid - owed
    //   4. DebtRecord listesini oluştur
    //   5. List<BalanceModel> döndür
    throw UnimplementedError(
        'calculateBalances henüz implementasyonu yapılmadı.');
  }

  @override
  Future<List<SettlementModel>> calculateSettlements(String roomId) async {
    // TODO [Developer 5]: Uygulama adımları:
    //   1. calculateBalances() çağır
    //   2. Sadece net != 0 olan üyeleri al
    //   3. Alacaklıları ve borçluları ayır
    //   4. Minimum transfer algoritması uygula
    //   5. List<SettlementModel> döndür
    throw UnimplementedError(
        'calculateSettlements henüz implementasyonu yapılmadı.');
  }

  @override
  Future<BalanceModel> getMemberBalance({
    required String roomId,
    required String memberId,
  }) async {
    // TODO [Developer 5]: calculateBalances() sonucundan filtrele
    throw UnimplementedError(
        'getMemberBalance henüz implementasyonu yapılmadı.');
  }
}
