import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../data/models/expense_entry.dart';
import '../../application/expense_providers.dart';
import 'add_transaction_sheet.dart';

class TransactionList extends ConsumerWidget {
  const TransactionList({
    super.key,
    this.entries,
    this.limit = 50,
    this.emptyTitle = 'No transactions yet',
    this.emptyMessage = 'Add your first income or expense',
  });

  final List<ExpenseEntry>? entries;
  final int? limit;
  final String emptyTitle;
  final String emptyMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final allEntries = ref.watch(expensesProvider);
    final visibleEntries = entries ?? allEntries;
    final currency = NumberFormat.simpleCurrency();

    if (visibleEntries.isEmpty) {
      return AppCard(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            const Text('💸', style: TextStyle(fontSize: 32)),
            const SizedBox(height: AppSpacing.md),
            Text(emptyTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              emptyMessage,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        for (final entry in visibleEntries.take(limit ?? visibleEntries.length))
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: AppCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color:
                          (entry.type == TransactionType.expense
                                  ? AppColors.danger
                                  : AppColors.success)
                              .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Text(
                      entry.categoryEmoji,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.note ?? entry.categoryLabel,
                          style: theme.textTheme.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          DateFormat('MMM d, HH:mm').format(entry.date),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${entry.type == TransactionType.expense ? '-' : '+'}${currency.format(entry.amount)}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: entry.type == TransactionType.expense
                          ? AppColors.danger
                          : AppColors.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'Transaction actions',
                    onSelected: (action) async {
                      if (action == 'edit') {
                        await showModalBottomSheet<void>(
                          context: context,
                          isScrollControlled: true,
                          useSafeArea: true,
                          builder: (_) => AddTransactionSheet(entry: entry),
                        );
                      } else if (action == 'delete') {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: Text(
                              'Delete ${entry.type == TransactionType.income ? 'income' : 'expense'}?',
                            ),
                            content: const Text(
                              'This transaction will be permanently removed.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(dialogContext, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(dialogContext, true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          await ref
                              .read(expensesProvider.notifier)
                              .delete(entry.id);
                        }
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
