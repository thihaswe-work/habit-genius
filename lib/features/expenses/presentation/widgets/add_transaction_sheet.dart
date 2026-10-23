import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/id_x.dart';
import '../../../../data/models/custom_category.dart';
import '../../../../data/models/expense_entry.dart';
import '../../application/category_providers.dart';
import '../../application/expense_providers.dart';
import 'category_dialog.dart';

class AddTransactionSheet extends ConsumerStatefulWidget {
  const AddTransactionSheet({super.key});

  @override
  ConsumerState<AddTransactionSheet> createState() =>
      _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<AddTransactionSheet> {
  TransactionType _type = TransactionType.expense;
  ExpenseCategory _category = ExpenseCategory.food;
  String? _customCategoryId;
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final custom = ref.watch(categoriesForTypeProvider(_type));
    final cats = _type == TransactionType.expense
        ? [
            ExpenseCategory.food,
            ExpenseCategory.transport,
            ExpenseCategory.shopping,
            ExpenseCategory.bills,
            ExpenseCategory.health,
            ExpenseCategory.fun,
            ExpenseCategory.other,
          ]
        : [ExpenseCategory.salary, ExpenseCategory.other];

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.gutter,
        right: AppSpacing.gutter,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Add transaction', style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.lg),
            SegmentedButton<TransactionType>(
              segments: const [
                ButtonSegment(
                  value: TransactionType.expense,
                  label: Text('Expense'),
                  icon: Icon(Icons.arrow_downward_rounded,
                      color: AppColors.danger),
                ),
                ButtonSegment(
                  value: TransactionType.income,
                  label: Text('Income'),
                  icon: Icon(Icons.arrow_upward_rounded,
                      color: AppColors.success),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (s) {
                setState(() {
                  _type = s.first;
                  _category = s.first == TransactionType.expense
                      ? ExpenseCategory.food
                      : ExpenseCategory.salary;
                  _customCategoryId = null;
                });
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _amountCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Category', style: theme.textTheme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final c in cats)
                  _CategoryChip(
                    emoji: c.emoji,
                    label: c.label,
                    selected:
                        _customCategoryId == null && _category == c,
                    type: _type,
                    onTap: () => setState(() {
                      _category = c;
                      _customCategoryId = null;
                    }),
                  ),
                for (final c in custom)
                  _CategoryChip(
                    emoji: c.emoji,
                    label: c.label,
                    selected: _customCategoryId == c.id,
                    type: _type,
                    onTap: () => setState(() {
                      _category = ExpenseCategory.other;
                      _customCategoryId = c.id;
                    }),
                  ),
                _NewCategoryChip(
                  onTap: () async {
                    final created = await showCreateCategoryDialog(
                      context,
                      type: _type,
                      onCreate: (label, emoji) => ref
                          .read(customCategoriesProvider.notifier)
                          .create(label: label, emoji: emoji, type: _type),
                    );
                    if (created != null && mounted) {
                      setState(() {
                        _category = ExpenseCategory.other;
                        _customCategoryId = created.id;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _noteCtrl,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                hintText: 'What was this for?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  backgroundColor: _type == TransactionType.expense
                      ? AppColors.danger
                      : AppColors.success,
                ),
                child: Text(
                  _type == TransactionType.expense ? 'Add expense' : 'Add income',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0;
    if (amount <= 0) return;
    CustomCategory? custom;
    if (_customCategoryId != null) {
      final all = ref.read(customCategoriesProvider);
      final index = all.indexWhere((c) => c.id == _customCategoryId);
      if (index != -1) custom = all[index];
    }
    final entry = ExpenseEntry(
      id: newId(),
      date: DateTime.now(),
      amount: amount,
      type: _type,
      category: custom == null ? _category : ExpenseCategory.other,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      customCategory: custom?.label,
      customEmoji: custom?.emoji,
    );
    ref.read(expensesProvider.notifier).add(entry);
    Navigator.of(context).pop();
  }
}


class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.emoji,
    required this.label,
    required this.selected,
    required this.type,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final bool selected;
  final TransactionType type;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = type == TransactionType.expense
        ? AppColors.danger
        : AppColors.success;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected
              ? accent.withValues(alpha: 0.12)
              : theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          border: Border.all(
            color: selected ? accent : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji),
            const SizedBox(width: AppSpacing.xs),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class _NewCategoryChip extends StatelessWidget {
  const _NewCategoryChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, size: 16),
            SizedBox(width: AppSpacing.xs),
            Text('New'),
          ],
        ),
      ),
    );
  }
}
