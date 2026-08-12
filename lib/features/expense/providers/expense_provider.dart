import 'package:flutter/foundation.dart';
import '../models/expense_model.dart';
import '../repositories/expense_repository.dart';
import '../../room/models/room_model.dart';

/// Harcama yönetimi state enum'u.
enum ExpenseStatus { idle, loading, success, error }

/// Harcama yönetimi provider'ı.
///
/// Developer 3 (Expense Management) bu provider'ı yönetir.
///
/// Sorumluluklar:
///   - Harcama CRUD operasyonları
///   - Seçili üye takibi (split için)
///   - Harcama formu state yönetimi
class ExpenseProvider extends ChangeNotifier {
  ExpenseProvider({IExpenseRepository? expenseRepository})
    : _expenseRepository = expenseRepository ?? const ExpenseRepository();

  final IExpenseRepository _expenseRepository;

  // ── State ─────────────────────────────────────────────────────────────────

  ExpenseStatus _status = ExpenseStatus.idle;
  ExpenseStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _status == ExpenseStatus.loading;
  bool get hasError => _status == ExpenseStatus.error;

  List<ExpenseModel> _expenses = [];
  List<ExpenseModel> get expenses => List.unmodifiable(_expenses);

  ExpenseModel? _selectedExpense;
  ExpenseModel? get selectedExpense => _selectedExpense;

  /// Harcama formu için seçili üyeler (split)
  List<MemberModel> _selectedParticipants = [];
  List<MemberModel> get selectedParticipants =>
      List.unmodifiable(_selectedParticipants);

  /// Özel split tutarları (memberId -> amount)
  Map<String, double> _customSplitAmounts = {};
  Map<String, double> get customSplitAmounts =>
      Map.unmodifiable(_customSplitAmounts);

  SplitType _splitType = SplitType.equal;
  SplitType get splitType => _splitType;

  // ── Aksiyon Metodları ────────────────────────────────────────────────────

  /// Oda harcamalarını yükler.
  ///
  /// TODO [Developer 3]: [_expenseRepository.getExpensesByRoom] çağrısı yapın.
  Future<void> loadExpenses(String roomId) async {
    _setLoading();

    try {
      // TODO [Developer 3]: Repository çağrısını implement edin.
      _expenses = await _expenseRepository.getExpensesByRoom(roomId);
      _setSuccess();
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Seçili harcamayı yükler.
  ///
  /// TODO [Developer 3]: [_expenseRepository.getExpenseById] çağrısı yapın.
  Future<void> loadExpenseById(String expenseId) async {
    _setLoading();

    try {
      // TODO [Developer 3]: Repository çağrısını implement edin.
      _selectedExpense = await _expenseRepository.getExpenseById(expenseId);
      _setSuccess();
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Yeni harcama oluşturur.
  ///
  /// TODO [Developer 3]: [_expenseRepository.createExpense] çağrısı yapın.
  Future<void> createExpense(ExpenseModel expense) async {
    _setLoading();

    try {
      // 1. Veritabanına (Supabase) harcamayı kaydet
      await _expenseRepository.createExpense(expense);

      // NOT: 2 ve 3. adımlardaki Split (kişilere bölüştürme) mantığını
      // ileride buraya ekleyeceksin. Şimdilik listeye ekleyip ekranı yeniliyoruz.

      // 4. Ekranda görünmesi için listeye ekle ve UI'a haber ver
      _expenses.add(expense);
      notifyListeners(); // <-- Ekranın "yenilendim!" demesini sağlayan sihirli kod bu

      _setSuccess();
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Harcamayı siler.

  Future<void> deleteExpense(String expenseId) async {
    _setLoading();

    try {
      // Veritabanından sil
      await _expenseRepository.deleteExpense(expenseId);

      // Ekrandaki listeden de çıkar ve UI'a haber ver
      _expenses = _expenses.where((e) => e.id != expenseId).toList();
      notifyListeners(); // <-- Bunu mutlaka ekle ki sildiğin an ekrandan da kaysın

      _setSuccess();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // ── Split Yönetimi ────────────────────────────────────────────────────────

  /// Split tipini değiştirir.
  void setSplitType(SplitType type) {
    _splitType = type;
    notifyListeners();
  }

  /// Katılımcı seçimini toggle'lar.
  void toggleParticipant(MemberModel member) {
    final updated = [..._selectedParticipants];
    if (updated.any((m) => m.id == member.id)) {
      updated.removeWhere((m) => m.id == member.id);
    } else {
      updated.add(member);
    }
    _selectedParticipants = updated;
    notifyListeners();
  }

  /// Tüm katılımcıları seçer.
  void selectAllParticipants(List<MemberModel> allMembers) {
    _selectedParticipants = [...allMembers];
    notifyListeners();
  }

  /// Özel split tutarını günceller.
  void setCustomSplitAmount(String memberId, double amount) {
    _customSplitAmounts = {..._customSplitAmounts, memberId: amount};
    notifyListeners();
  }

  /// Harcama form state'ini sıfırlar.
  void resetForm() {
    _selectedParticipants = [];
    _customSplitAmounts = {};
    _splitType = SplitType.equal;
    notifyListeners();
  }

  // ── Private Yardımcı Metodlar ─────────────────────────────────────────────

  void _setLoading() {
    _status = ExpenseStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setSuccess() {
    _status = ExpenseStatus.success;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = ExpenseStatus.error;
    _errorMessage = message;
    notifyListeners();
  }
}
