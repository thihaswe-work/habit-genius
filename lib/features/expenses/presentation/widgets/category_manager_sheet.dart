import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../data/models/custom_category.dart';
import '../../../../data/models/expense_entry.dart';
import '../../application/category_providers.dart';
import 'category_dialog.dart';

/// Lets the user create and remove custom income/expense categories.
class CategoryManagerSheet extends ConsumerWidget {
  const CategoryManagerSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final expense =
        ref.watch(categoriesForTypeProvider(TransactionType.expense));
    final income =
        ref.watch(categoriesForTypeProvider(TransactionType.income));

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
            Text('Custom categories', style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Create your own menus for expenses and income.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            _Section(
              title: 'Expense',
              color: AppColors.danger,
              categories: expense,
              onAdd: () => _create(context, ref, TransactionType.expense),
              onDelete: (c) => _delete(context, ref, c),
            ),
            const SizedBox(height: AppSpacing.lg),
            _Section(
              title: 'Income',
              color: AppColors.success,
              categories: income,
              onAdd: () => _create(context, ref, TransactionType.income),
              onDelete: (c) => _delete(context, ref, c),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _create(
    BuildContext context,
    WidgetRef ref,
    TransactionType type,
  ) async {
    await showCreateCategoryDialog(
      context,
      type: type,
      onCreate: (label, emoji) => ref
          .read(customCategoriesProvider.notifier)
          .create(label: label, emoji: emoji, type: type),
    );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    CustomCategory category,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete category?'),
        content: Text(
          'Remove "${category.label}"? Existing transactions keep their label.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(customCategoriesProvider.notifier).delete(category.id);
    }
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.color,
    required this.categories,
    required this.onAdd,
    required this.onDelete,
  });

  final String title;
  final Color color;
  final List<CustomCategory> categories;
  final VoidCallback onAdd;
  final ValueChanged<CustomCategory> onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const Spacer(),
            TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add'),
            ),
          ],
        ),
        if (categories.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Text(
              'No custom $title categories yet.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final category in categories)
                InputChip(
                  avatar: Text(category.emoji),
                  label: Text(category.label),
                  onDeleted: () => onDelete(category),
                  deleteIcon: const Icon(Icons.close_rounded, size: 16),
                  side: BorderSide(color: color.withValues(alpha: 0.3)),
                ),
            ],
          ),
      ],
    );
  }
}
