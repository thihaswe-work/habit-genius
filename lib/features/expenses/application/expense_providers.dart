import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/date_x.dart';
import '../../../data/models/expense_entry.dart';
import '../../../data/repositories/repository_providers.dart';

/// Today's income, spending and net balance.
class ExpenseSummary {
  const ExpenseSummary({
    required this.income,
    required this.expense,
  });

  final double income;
  final double expense;

  double get balance => income - expense;

  bool get hasActivity => income > 0 || expense > 0;
}

/// All transactions, newest first.
final expensesProvider =
    NotifierProvider<ExpensesNotifier, List<ExpenseEntry>>(ExpensesNotifier.new);

/// Today's income / expense totals.
final todayExpenseSummaryProvider = Provider<ExpenseSummary>((Ref ref) {
  final entries = ref.watch(expensesProvider);
  final today = DateTime.now();

  var income = 0.0;
  var expense = 0.0;
  for (final entry in entries) {
    if (!entry.date.isSameDay(today)) continue;
    if (entry.type == TransactionType.income) {
      income += entry.amount;
    } else {
      expense += entry.amount;
    }
  }
  return ExpenseSummary(income: income, expense: expense);
});

/// Manages transactions.
class ExpensesNotifier extends Notifier<List<ExpenseEntry>> {
  @override
  List<ExpenseEntry> build() => ref.read(expenseRepositoryProvider).getAll();

  /// Adds a transaction.
  Future<void> add(ExpenseEntry entry) async {
    final repository = ref.read(expenseRepositoryProvider);
    await repository.add(entry);
    state = repository.getAll();
  }

  /// Updates a transaction.
  Future<void> update(ExpenseEntry entry) async {
    final repository = ref.read(expenseRepositoryProvider);
    await repository.update(entry);
    state = repository.getAll();
  }

  /// Deletes a transaction.
  Future<void> delete(String id) async {
    final repository = ref.read(expenseRepositoryProvider);
    await repository.delete(id);
    state = repository.getAll();
  }
}
