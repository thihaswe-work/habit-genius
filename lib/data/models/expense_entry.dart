import 'package:flutter/foundation.dart';

/// Whether a transaction adds or removes money.
enum TransactionType { income, expense }

/// Spending categories offered by the tracker.
enum ExpenseCategory {
  food('Food', '🍔'),
  transport('Transport', '🚕'),
  shopping('Shopping', '🛍️'),
  bills('Bills', '🧾'),
  health('Health', '💊'),
  fun('Fun', '🎬'),
  salary('Salary', '💰'),
  other('Other', '📦');

  const ExpenseCategory(this.label, this.emoji);

  final String label;
  final String emoji;
}

/// A single income or expense record.
@immutable
class ExpenseEntry {
  const ExpenseEntry({
    required this.id,
    required this.date,
    required this.amount,
    required this.type,
    required this.category,
    this.note,
  });

  final String id;
  final DateTime date;

  /// Always stored as a positive number; [type] carries the direction.
  final double amount;
  final TransactionType type;
  final ExpenseCategory category;
  final String? note;

  /// Signed value used when summing balances.
  double get signedAmount =>
      type == TransactionType.income ? amount : -amount;

  ExpenseEntry copyWith({
    String? id,
    DateTime? date,
    double? amount,
    TransactionType? type,
    ExpenseCategory? category,
    String? note,
  }) {
    return ExpenseEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      note: note ?? this.note,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseEntry &&
          other.id == id &&
          other.date == date &&
          other.amount == amount &&
          other.type == type &&
          other.category == category &&
          other.note == note;

  @override
  int get hashCode => Object.hash(id, date, amount, type, category, note);
}

extension ExpenseEntryJson on ExpenseEntry {
  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'amount': amount,
        'typeIndex': type.index,
        'categoryIndex': category.index,
        'note': note,
      };

  static ExpenseEntry fromJson(Map<String, dynamic> json) => ExpenseEntry(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        amount: (json['amount'] as num).toDouble(),
        type: TransactionType.values[json['typeIndex'] as int],
        category: ExpenseCategory.values[json['categoryIndex'] as int],
        note: json['note'] as String?,
      );
}
