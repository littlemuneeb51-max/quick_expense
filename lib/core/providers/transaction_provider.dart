import 'package:flutter/material.dart';
import 'package:quick_expense/core/database/database_service.dart';
import 'package:quick_expense/models/transaction_model.dart';

/// State management provider for handling Transaction lists, additions,
/// deletions, and computing balance analytics dynamically.
class TransactionProvider extends ChangeNotifier {
  List<Transaction> _transactions = [];

  /// Get the read-only list of transactions
  List<Transaction> get transactions => _transactions;

  /// Fetches transactions from the local database and notifies observers.
  void loadTransactions() {
    _transactions = DatabaseService.instance.getTransactions();
    notifyListeners();
  }

  /// Calculates net balance (Total Income - Total Expenses)
  double get totalBalance => totalIncome - totalExpense;

  /// Sum of all income transactions
  double get totalIncome {
    return _transactions
        .where((tx) => tx.isIncome)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  /// Sum of all expense transactions
  double get totalExpense {
    return _transactions
        .where((tx) => !tx.isIncome)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  /// Adds a transaction to local storage and refreshes state.
  Future<void> addTransaction(Transaction transaction) async {
    await DatabaseService.instance.saveTransaction(transaction);
    // Reload list to ensure sorting by date remains consistent
    loadTransactions();
  }

  /// Deletes a transaction by ID from local storage and updates state.
  Future<void> deleteTransaction(String id) async {
    await DatabaseService.instance.deleteTransaction(id);
    _transactions.removeWhere((tx) => tx.id == id);
    notifyListeners();
  }

  /// Clears all transactions from local storage and resets state.
  Future<void> clearAllTransactions() async {
    await DatabaseService.instance.clearAll();
    _transactions.clear();
    notifyListeners();
  }
}
