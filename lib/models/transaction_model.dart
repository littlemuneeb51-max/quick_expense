import 'package:hive/hive.dart';

part 'transaction_model.g.dart';

/// Transaction Model representing an Income or Expense item.
/// Annotations enable automatic generation of a Hive binary TypeAdapter.
@HiveType(typeId: 0)
class Transaction extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final bool isIncome;

  @HiveField(4)
  final String category;

  @HiveField(5)
  final DateTime date;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.isIncome,
    required this.category,
    required this.date,
  });
}
