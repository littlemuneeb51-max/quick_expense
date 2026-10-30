import 'package:hive_flutter/hive_flutter.dart';
import 'package:quick_expense/models/transaction_model.dart';

/// Offline Database Service powered by Hive.
/// Manages connection, adapter registration, and CRUD transactions.
class DatabaseService {
  static const String _boxName = 'transactions';
  late Box<Transaction> _box;

  // Private constructor for singleton pattern
  DatabaseService._();

  // Singleton instance
  static final DatabaseService instance = DatabaseService._();

  /// Initializes Hive and registers the generated TypeAdapter.
  Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapter safely (ensuring it's not registered twice)
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TransactionAdapter());
    }

    // Open the transactions box
    _box = await Hive.openBox<Transaction>(_boxName);
  }

  /// Setup method for unit/widget testing
  void initForTests(Box<Transaction> testBox) {
    _box = testBox;
  }

  /// Retrieve all transactions sorted by date descending.
  List<Transaction> getTransactions() {
    final list = _box.values.toList();
    // Sort transactions so recent entries appear first
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  /// Save or update a transaction using its unique ID as key.
  Future<void> saveTransaction(Transaction transaction) async {
    await _box.put(transaction.id, transaction);
  }

  /// Delete a transaction from local storage.
  Future<void> deleteTransaction(String id) async {
    await _box.delete(id);
  }

  /// Clear database (useful for resetting data)
  Future<void> clearAll() async {
    await _box.clear();
  }
}
