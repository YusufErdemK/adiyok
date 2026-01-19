import 'package:flutter/material.dart';
import '../models/transaction.dart';
import 'tree_provider.dart';

class TransactionProvider extends ChangeNotifier {
  final List<Transaction> _transactions = [];
  final TreeProvider? _treeProvider;

  TransactionProvider({TreeProvider? treeProvider})
    : _treeProvider = treeProvider;

  /// Tüm işlemleri al
  List<Transaction> get transactions => _transactions;

  /// Gelir ve giderleri al
  List<Transaction> get incomes =>
      _transactions.where((t) => t.isIncome).toList();

  List<Transaction> get expenses =>
      _transactions.where((t) => t.isExpense).toList();

  /// Toplam geliri hesapla
  double get totalIncome =>
      incomes.fold(0, (sum, transaction) => sum + transaction.amount);

  /// Toplam gideri hesapla
  double get totalExpense =>
      expenses.fold(0, (sum, transaction) => sum + transaction.amount);

  /// Net geliri hesapla
  double get netIncome => totalIncome - totalExpense;

  /// Kategori bazında toplam
  double getCategoryTotal(TransactionCategory category) {
    return _transactions
        .where((t) => t.category == category)
        .fold(0, (sum, t) => sum + t.amount);
  }

  /// Ay bazında gelir/gider
  Map<String, double> getMonthlyIncome() {
    final monthly = <String, double>{};
    for (var transaction in incomes) {
      final monthKey =
          '${transaction.date.year}-${transaction.date.month.toString().padLeft(2, '0')}';
      monthly[monthKey] = (monthly[monthKey] ?? 0) + transaction.amount;
    }
    return monthly;
  }

  Map<String, double> getMonthlyExpense() {
    final monthly = <String, double>{};
    for (var transaction in expenses) {
      final monthKey =
          '${transaction.date.year}-${transaction.date.month.toString().padLeft(2, '0')}';
      monthly[monthKey] = (monthly[monthKey] ?? 0) + transaction.amount;
    }
    return monthly;
  }

  /// Yeni işlem ekle
  void addTransaction(Transaction transaction) {
    _transactions.add(transaction);
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  /// İşlem sil
  void deleteTransaction(String transactionId) {
    _transactions.removeWhere((t) => t.id == transactionId);
    notifyListeners();
  }

  /// İşlem güncelle
  void updateTransaction(String transactionId, Transaction updatedTransaction) {
    final index = _transactions.indexWhere((t) => t.id == transactionId);
    if (index != -1) {
      _transactions[index] = updatedTransaction;
      _transactions.sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();
    }
  }

  /// Belirtilen tarih aralığındaki işlemleri al
  List<Transaction> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    return _transactions
        .where(
          (t) =>
              t.date.isAfter(startDate) &&
              t.date.isBefore(endDate.add(const Duration(days: 1))),
        )
        .toList();
  }

  /// Bu ayın işlemlerini al
  List<Transaction> getCurrentMonthTransactions() {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    return getTransactionsByDateRange(firstDayOfMonth, lastDayOfMonth);
  }

  /// Tüm işlemleri temizle
  void clearAllTransactions() {
    _transactions.clear();
    notifyListeners();
  }

  /// Kategori bazında filtrelenmiş işlemler
  List<Transaction> getTransactionsByCategory(TransactionCategory category) {
    return _transactions.where((t) => t.category == category).toList();
  }
}
