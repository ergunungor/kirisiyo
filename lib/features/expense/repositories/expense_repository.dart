import 'package:supabase_flutter/supabase_flutter.dart';

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

class ExpenseRepository implements IExpenseRepository {
  const ExpenseRepository();

  get _supabase => Supabase.instance.client;
  @override
  Future<List<ExpenseModel>> getExpensesByRoom(String roomId) async {
    try {
      // 1 & 2. Odaya ait harcamaları ve onlara bağlı split'leri (kim ne kadar ödedi) çek
      final response = await _supabase
          .from('expenses')
          .select('*, expense_splits(*)') // JOIN işlemi
          .eq('room_id', roomId)
          .order(
            'expense_date',
            ascending: false,
          ); // Tarihe göre yeni olan en üstte

      // 3. Gelen veriyi List<ExpenseModel> olarak döndür
      return (response as List).map((e) => ExpenseModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Oda harcamaları getirilemedi: $e');
    }
  }

  @override
  Future<ExpenseModel> getExpenseById(String id) async {
    try {
      final response =
          await _supabase
              .from('expenses')
              .select('*, expense_splits(*)')
              .eq('id', id)
              .single(); // Tek bir harcama dönmesini bekliyoruz

      return ExpenseModel.fromJson(response);
    } catch (e) {
      throw Exception('Harcama detayı getirilemedi: $e');
    }
  }

  @override
  Future<ExpenseModel> createExpense(ExpenseModel expense) async {
    try {
      // 1. expenses tablosuna INSERT yap ve eklenen veriyi geri iste (.select().single())
      final response =
          await _supabase
              .from('expenses')
              .insert(expense.toJson())
              .select()
              .single();

      final createdExpense = ExpenseModel.fromJson(response);

      // 2. Eğer harcamanın içinde kişilere bölünmüş tutarlar (splits) varsa onları da kaydet
      // (Eğer modelinizde splits diye bir liste yoksa bu if bloğunu silebilirsin)
      if (expense.splits != null && expense.splits!.isNotEmpty) {
        await saveExpenseSplits(expense.splits!);
      }

      // 3. Güncel modeli döndür
      return createdExpense;
    } catch (e) {
      throw Exception('Harcama oluşturulamadı: $e');
    }
  }

  @override
  Future<ExpenseModel> updateExpense(ExpenseModel expense) async {
    try {
      // expenses tablosunu UPDATE yap
      final response =
          await _supabase
              .from('expenses')
              .update(expense.toJson())
              .eq('id', expense.id) // Sadece bu id'ye sahip olanı güncelle
              .select()
              .single();

      return ExpenseModel.fromJson(response);
    } catch (e) {
      throw Exception('Harcama güncellenemedi: $e');
    }
  }

  @override
  Future<void> deleteExpense(String id) async {
    try {
      // expenses tablosundan DELETE yap (CASCADE ayarlıysa splits otomatik silinir)
      await _supabase.from('expenses').delete().eq('id', id);
    } catch (e) {
      throw Exception('Harcama silinemedi: $e');
    }
  }

  @override
  Future<void> saveExpenseSplits(List<ExpenseSplitModel> splits) async {
    if (splits.isEmpty) return;

    try {
      final expenseId = splits.first.expenseId;

      // Önce mevcut kayıtları sil (Temizlik)
      await _supabase
          .from('expense_splits')
          .delete()
          .eq('expense_id', expenseId);

      // Sonra yeni kayıtları topluca INSERT et
      final splitsData = splits.map((s) => s.toJson()).toList();
      await _supabase.from('expense_splits').insert(splitsData);
    } catch (e) {
      throw Exception('Harcama bölüştürmeleri kaydedilemedi: $e');
    }
  }

  @override
  Future<ExpenseModel> attachReceiptPhoto({
    required String expenseId,
    required String photoUrl,
  }) async {
    try {
      final response =
          await _supabase
              .from('expenses')
              .update({'image_url': photoUrl})
              .eq('id', expenseId)
              .select()
              .single();

      return ExpenseModel.fromJson(response);
    } catch (e) {
      throw Exception('Fiş fotoğrafı eklenemedi: $e');
    }
  }
}
