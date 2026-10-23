import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/heatmap_data.dart';
import '../../../../data/models/habit.dart';

class ConsistencyHeatmap extends StatelessWidget {
  const ConsistencyHeatmap({
    super.key,
    required this.habits,
    this.days = 140,
  });

  final List<Habit> habits;
  final int days;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cells = HeatmapDataGenerator.generate(habits, days: days);
    final weeks = <List<HeatmapCell>>[];
    for (int i = 0; i < cells.length; i += 7) {
      weeks.add(cells.skip(i).take(7).toList());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Consistency', style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.md),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final week in weeks)
                Column(
                  children: [
                    for (final cell in week)
                      Padding(
                        padding: const EdgeInsets.all(2),
                        child: Tooltip(
                          message:
                              '${cell.date.month}/${cell.date.day}: ${cell.count} completed',
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: HeatmapDataGenerator.getColor(
                                cell.level,
                                theme.colorScheme,
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Text('Less', style: theme.textTheme.labelSmall),
            const SizedBox(width: AppSpacing.sm),
            for (int i = 0; i < 5; i++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: HeatmapDataGenerator.getColor(
                      i,
                      theme.colorScheme,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            const SizedBox(width: AppSpacing.sm),
            Text('More', style: theme.textTheme.labelSmall),
          ],
        ),
      ],
    );
  }
}
