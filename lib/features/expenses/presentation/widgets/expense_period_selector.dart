import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../data/models/expense_entry.dart';
import '../../application/expense_providers.dart';

class ExpensePeriodSelector extends ConsumerWidget {
  const ExpensePeriodSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(expenseHistorySelectionProvider);
    final entries = ref.watch(expensesProvider);
    final today = DateTime.now();
    final firstDate = _firstDate(entries, today);
    final label = selection.period == ExpenseHistoryPeriod.month
        ? DateFormat.yMMMM().format(selection.date)
        : DateFormat.y().format(selection.date);
    final previousDate = selection.period == ExpenseHistoryPeriod.month
        ? DateTime(selection.date.year, selection.date.month - 1, 1)
        : DateTime(selection.date.year - 1, 1);
    final nextDate = selection.period == ExpenseHistoryPeriod.month
        ? DateTime(selection.date.year, selection.date.month + 1, 1)
        : DateTime(selection.date.year + 1, 1);
    final earliestPeriod = selection.period == ExpenseHistoryPeriod.month
        ? DateTime(firstDate.year, firstDate.month, 1)
        : DateTime(firstDate.year, 1);
    final currentPeriod = selection.period == ExpenseHistoryPeriod.month
        ? DateTime(today.year, today.month, 1)
        : DateTime(today.year, 1);

    Future<void> pickDate() async {
      final picked = await showDatePicker(
        context: context,
        initialDate: selection.date,
        firstDate: firstDate,
        lastDate: today,
        initialDatePickerMode: selection.period == ExpenseHistoryPeriod.year
            ? DatePickerMode.year
            : DatePickerMode.day,
        helpText: selection.period == ExpenseHistoryPeriod.month
            ? 'Choose a month'
            : 'Choose a year',
      );
      if (picked != null) {
        ref.read(expenseHistorySelectionProvider.notifier).setDate(picked);
      }
    }

    return Column(
      children: <Widget>[
        Center(
          child: SegmentedButton<ExpenseHistoryPeriod>(
            segments: const <ButtonSegment<ExpenseHistoryPeriod>>[
              ButtonSegment(
                value: ExpenseHistoryPeriod.month,
                label: Text('Month'),
                icon: Icon(Icons.calendar_view_month_rounded),
              ),
              ButtonSegment(
                value: ExpenseHistoryPeriod.year,
                label: Text('Year'),
                icon: Icon(Icons.calendar_today_rounded),
              ),
            ],
            selected: <ExpenseHistoryPeriod>{selection.period},
            onSelectionChanged: (selected) => ref
                .read(expenseHistorySelectionProvider.notifier)
                .setPeriod(selected.first),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: <Widget>[
            IconButton(
              tooltip: 'Previous ${selection.period.name}',
              onPressed: previousDate.isBefore(earliestPeriod)
                  ? null
                  : () => ref
                        .read(expenseHistorySelectionProvider.notifier)
                        .move(-1),
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            Expanded(
              child: TextButton.icon(
                onPressed: pickDate,
                icon: const Icon(Icons.calendar_month_rounded),
                label: Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Next ${selection.period.name}',
              onPressed: nextDate.isAfter(currentPeriod)
                  ? null
                  : () => ref
                        .read(expenseHistorySelectionProvider.notifier)
                        .move(1),
              icon: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
      ],
    );
  }

  DateTime _firstDate(List<ExpenseEntry> entries, DateTime today) {
    if (entries.isEmpty) return DateTime(today.year - 10);
    final earliest = entries
        .map((entry) => entry.date)
        .reduce((a, b) => a.isBefore(b) ? a : b);
    if (earliest.isAfter(today)) return DateTime(today.year - 10);
    return DateTime(earliest.year, earliest.month, earliest.day);
  }
}
