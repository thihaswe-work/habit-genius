import 'package:flutter_test/flutter_test.dart';
import 'package:habit_genius/data/models/custom_category.dart';
import 'package:habit_genius/data/models/expense_entry.dart';

void main() {
  test('custom category round trips through JSON', () {
    const category = CustomCategory(
      id: 'c1',
      label: 'Freelance',
      emoji: '💼',
      type: TransactionType.income,
    );
    final decoded = CustomCategoryJson.fromJson(category.toJson());
    expect(decoded, category);
  });

  test('expense entry supports custom category overrides', () {
    final entry = ExpenseEntry(
      id: 'e1',
      date: DateTime(2026, 10, 23),
      amount: 12.5,
      type: TransactionType.expense,
      category: ExpenseCategory.other,
      customCategory: 'Coffee',
      customEmoji: '☕',
    );
    expect(entry.categoryLabel, 'Coffee');
    expect(entry.categoryEmoji, '☕');
    final decoded = ExpenseEntryJson.fromJson(entry.toJson());
    expect(decoded.customCategory, 'Coffee');
    expect(decoded.customEmoji, '☕');
  });

  test('legacy expense JSON without custom fields parses', () {
    final decoded = ExpenseEntryJson.fromJson({
      'id': 'old',
      'date': '2026-10-23T00:00:00.000',
      'amount': 5,
      'typeIndex': 1,
      'categoryIndex': 0,
      'note': null,
    });
    expect(decoded.categoryLabel, 'Food');
    expect(decoded.customCategory, isNull);
  });
}
