import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../services/storage_service.dart';
import 'tree_provider.dart';

class TransactionProvider extends ChangeNotifier {
  final List<Transaction> _transactions = [];
  final TreeProvider? _treeProvider;
  bool _isLoading = true;

  TransactionProvider({TreeProvider? treeProvider})
    : _treeProvider = treeProvider {
    _initializeTransactions();
  }

  Future<void> _initializeTransactions() async {
    _transactions.clear();
    _transactions.addAll(await StorageService.loadTransactionData());
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    _isLoading = false;
    notifyListeners();
  }

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;

  List<Transaction> get incomes =>
      _transactions.where((t) => t.isIncome).toList();

  List<Transaction> get expenses =>
      _transactions.where((t) => t.isExpense).toList();

  double get totalIncome =>
      incomes.fold(0, (sum, t) => sum + t.amount * t.quantity);

  double get totalExpense =>
      expenses.fold(0, (sum, t) => sum + t.amount * t.quantity);

  double get netIncome => totalIncome - totalExpense;

  double getCategoryTotal(TransactionCategory category) {
    return _transactions
        .where((t) => t.category == category)
        .fold(0, (sum, t) => sum + t.amount * t.quantity);
  }

  Map<String, double> getMonthlyIncome() {
    final monthly = <String, double>{};
    for (var t in incomes) {
      final monthKey =
          '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}';
      monthly[monthKey] = (monthly[monthKey] ?? 0) + t.amount * t.quantity;
    }
    return monthly;
  }

  Map<String, double> getMonthlyExpense() {
    final monthly = <String, double>{};
    for (var t in expenses) {
      final monthKey =
          '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}';
      monthly[monthKey] = (monthly[monthKey] ?? 0) + t.amount * t.quantity;
    }
    return monthly;
  }

  void addTransaction(Transaction transaction) {
    _transactions.add(transaction);
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    _saveTransactionData();
    notifyListeners();
  }

  void deleteTransaction(String transactionId) {
    _transactions.removeWhere((t) => t.id == transactionId);
    _saveTransactionData();
    notifyListeners();
  }

  void updateTransaction(String transactionId, Transaction updatedTransaction) {
    final index = _transactions.indexWhere((t) => t.id == transactionId);
    if (index != -1) {
      _transactions[index] = updatedTransaction;
      _transactions.sort((a, b) => b.date.compareTo(a.date));
      _saveTransactionData();
      notifyListeners();
    }
  }

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

  List<Transaction> getCurrentMonthTransactions() {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    return getTransactionsByDateRange(firstDayOfMonth, lastDayOfMonth);
  }

  void clearAllTransactions() {
    _transactions.clear();
    _saveTransactionData();
    notifyListeners();
  }

  List<Transaction> getTransactionsByCategory(TransactionCategory category) {
    return _transactions.where((t) => t.category == category).toList();
  }

  Future<void> _saveTransactionData() async {
    await StorageService.saveTransactionData(_transactions);
  }
}
