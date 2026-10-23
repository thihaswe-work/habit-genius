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
    this.customCategory,
    this.customEmoji,
  });

  final String id;
  final DateTime date;

  /// Always stored as a positive number; [type] carries the direction.
  final double amount;
  final TransactionType type;
  final ExpenseCategory category;
  final String? note;

  /// Label of a user-defined category; when set it overrides [category].
  final String? customCategory;

  /// Emoji of a user-defined category; when set it overrides [category].
  final String? customEmoji;

  String get categoryLabel => customCategory ?? category.label;

  String get categoryEmoji => customEmoji ?? category.emoji;

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
    String? customCategory,
    String? customEmoji,
  }) {
    return ExpenseEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      note: note ?? this.note,
      customCategory: customCategory ?? this.customCategory,
      customEmoji: customEmoji ?? this.customEmoji,
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
          other.note == note &&
          other.customCategory == customCategory &&
          other.customEmoji == customEmoji;

  @override
  int get hashCode => Object.hash(
        id,
        date,
        amount,
        type,
        category,
        note,
        customCategory,
        customEmoji,
      );
}

extension ExpenseEntryJson on ExpenseEntry {
  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'amount': amount,
        'typeIndex': type.index,
        'categoryIndex': category.index,
        'note': note,
        'customCategory': customCategory,
        'customEmoji': customEmoji,
      };

  static ExpenseEntry fromJson(Map<String, dynamic> json) => ExpenseEntry(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        amount: (json['amount'] as num).toDouble(),
        type: TransactionType.values[json['typeIndex'] as int],
        category: ExpenseCategory.values[(json['categoryIndex'] as int?) ?? 7],
        note: json['note'] as String?,
        customCategory: json['customCategory'] as String?,
        customEmoji: json['customEmoji'] as String?,
      );
}
