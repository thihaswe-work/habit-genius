import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../data/models/habit.dart';

class WeeklyTrendBars extends StatelessWidget {
  const WeeklyTrendBars({super.key, required this.habits, this.days = 7});

  final List<Habit> habits;
  final int days;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final active = habits.where((h) => !h.isArchived).toList();
    final today = DateTime.now();
    final values = <({DateTime date, double ratio})>[];
    for (var i = days - 1; i >= 0; i--) {
      final date = DateTime(today.year, today.month, today.day)
          .subtract(Duration(days: i));
      if (active.isEmpty) {
        values.add((date: date, ratio: 0));
        continue;
      }
      final done = active.where((h) => h.isCompletedOn(date)).length;
      values.add((date: date, ratio: done / active.length));
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final v in values)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(v.ratio * 100).round()}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 8 + (v.ratio * 72),
                    decoration: BoxDecoration(
                      color: v.ratio >= 0.75
                          ? theme.colorScheme.primary
                          : theme.colorScheme.primary.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    DateFormat.E().format(v.date),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
