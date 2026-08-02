import '../models/expense_model.dart';

/// Harcama repository arayüzü.
///
/// Developer 3 (Expense Management) bu arayüzü implemente eder.
abstract interface class IExpenseRepository {
  /// Oda ID'sine göre tüm harcamaları listeler.
  Future<List<ExpenseModel>> getExpensesByRoom(String roomId);

  /// Harcama ID'sine göre tek harcamayı getirir.
  Future<ExpenseModel> getExpenseById(String id);

  /// Yeni harcama oluşturur.
  Future<ExpenseModel> createExpense(ExpenseModel expense);

  /// Harcamayı günceller.
  Future<ExpenseModel> updateExpense(ExpenseModel expense);

  /// Harcamayı siler.
  Future<void> deleteExpense(String id);

  /// Harcama bölüştürmelerini kaydeder.
  Future<void> saveExpenseSplits(List<ExpenseSplitModel> splits);

  /// Harcamaya fiş fotoğrafı URL'i ekler.
  Future<ExpenseModel> attachReceiptPhoto({
    required String expenseId,
    required String photoUrl,
  });
}

/// Harcama repository implementasyonu.
///
/// TODO [Developer 3]: Supabase sorgularını implement edin.
///   - expenses tablosundan SELECT WHERE room_id = ? (getExpensesByRoom)
///   - expenses tablosuna INSERT (createExpense)
///   - expenses tablosuna UPDATE (updateExpense)
///   - expenses tablosundan DELETE WHERE id = ? (deleteExpense)
///   - expense_splits tablosuna INSERT (saveExpenseSplits)
///
/// Supabase Storage'ı fiş fotoğrafları için kullanın (Dev 4 ile koordineli).
class ExpenseRepository implements IExpenseRepository {
  const ExpenseRepository();

  @override
  Future<List<ExpenseModel>> getExpensesByRoom(String roomId) async {
    // TODO [Developer 3]: Uygulama adımları:
    //   1. expenses tablosundan SELECT WHERE room_id = ? yap (date DESC sırala)
    //   2. expense_splits JOIN ile bölüştürmeleri de getir
    //   3. List<ExpenseModel> olarak döndür
    throw UnimplementedError(
        'getExpensesByRoom henüz implementasyonu yapılmadı.');
  }

  @override
  Future<ExpenseModel> getExpenseById(String id) async {
    // TODO [Developer 3]: expenses + expense_splits JOIN ile getir
    throw UnimplementedError('getExpenseById henüz implementasyonu yapılmadı.');
  }

  @override
  Future<ExpenseModel> createExpense(ExpenseModel expense) async {
    // TODO [Developer 3]: Uygulama adımları:
    //   1. expenses tablosuna INSERT yap
    //   2. splits doluysa saveExpenseSplits çağır
    //   3. Güncel ExpenseModel döndür
    throw UnimplementedError('createExpense henüz implementasyonu yapılmadı.');
  }

  @override
  Future<ExpenseModel> updateExpense(ExpenseModel expense) async {
    // TODO [Developer 3]: expenses tablosunu UPDATE yap
    throw UnimplementedError('updateExpense henüz implementasyonu yapılmadı.');
  }

  @override
  Future<void> deleteExpense(String id) async {
    // TODO [Developer 3]: expenses tablosundan DELETE yap
    //   CASCADE ile expense_splits de silinecektir (DB constraint)
    throw UnimplementedError('deleteExpense henüz implementasyonu yapılmadı.');
  }

  @override
  Future<void> saveExpenseSplits(List<ExpenseSplitModel> splits) async {
    // TODO [Developer 3]: expense_splits tablosuna toplu INSERT yap
    //   Önce mevcut kayıtları DELETE et, sonra yeni kayıtları INSERT et
    throw UnimplementedError(
        'saveExpenseSplits henüz implementasyonu yapılmadı.');
  }

  @override
  Future<ExpenseModel> attachReceiptPhoto({
    required String expenseId,
    required String photoUrl,
  }) async {
    // TODO [Developer 3 + Developer 4]: Uygulama adımları:
    //   1. expenses tablosunu UPDATE yap (photo_url = ?)
    //   2. Güncel ExpenseModel döndür
    throw UnimplementedError(
        'attachReceiptPhoto henüz implementasyonu yapılmadı.');
  }
}
