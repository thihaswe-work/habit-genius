import '../models/expense_entry.dart';

/// Persistence contract for income and expense records.
abstract interface class ExpenseRepository {
  /// All transactions, newest first.
  List<ExpenseEntry> getAll();

  /// Creates a new transaction.
  Future<void> add(ExpenseEntry entry);

  /// Updates an existing transaction.
  Future<void> update(ExpenseEntry entry);

  /// Removes the transaction with [id].
  Future<void> delete(String id);
}
