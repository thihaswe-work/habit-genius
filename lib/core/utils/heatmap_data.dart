import 'package:flutter/material.dart';

import '../../data/models/habit.dart';

/// Heatmap cell data
class HeatmapCell {
  const HeatmapCell({
    required this.date,
    required this.level,
    required this.count,
  });

  final DateTime date;
  final int level; // 0-4
  final int count;
}

/// Generate heatmap data for habits (GitHub style)
class HeatmapDataGenerator {
  static List<HeatmapCell> generate(List<Habit> habits, {int days = 365}) {
    final now = DateTime.now();
    final cells = <HeatmapCell>[];

    for (int i = days - 1; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      int completed = 0;
      for (final habit in habits) {
        if (!habit.isArchived && habit.isCompletedOn(date)) {
          completed++;
        }
      }
      int level = 0;
      if (habits.isNotEmpty) {
        final rate = completed / habits.length;
        if (rate >= 0.75) {
          level = 4;
        } else if (rate >= 0.5) {
          level = 3;
        } else if (rate >= 0.25) {
          level = 2;
        } else if (rate > 0) {
          level = 1;
        }
      }
      cells.add(HeatmapCell(date: date, level: level, count: completed));
    }
    return cells;
  }

  static Color getColor(int level, ColorScheme scheme) {
    switch (level) {
      case 0:
        return scheme.surfaceContainerHighest;
      case 1:
        return scheme.primary.withValues(alpha: 0.25);
      case 2:
        return scheme.primary.withValues(alpha: 0.45);
      case 3:
        return scheme.primary.withValues(alpha: 0.7);
      case 4:
        return scheme.primary;
      default:
        return scheme.surfaceContainerHighest;
    }
  }
}
