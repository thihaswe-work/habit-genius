import 'package:flutter/foundation.dart';

import '../../../core/utils/date_x.dart';
import '../../../data/models/habit.dart';

@immutable
class UpcomingReminder {
  const UpcomingReminder({
    required this.habitId,
    required this.habitName,
    required this.emoji,
    required this.at,
  });

  final String habitId;
  final String habitName;
  final String? emoji;
  final DateTime at;
}

/// Pure scheduling logic for habit reminders.
///
/// This computes *when* reminders should fire. Delivering them is handled by
/// the platform notification layer.
class ReminderScheduler {
  ReminderScheduler._();

  /// Next reminder for [habit], or null when it has no reminder time.
  static DateTime? nextFor(Habit habit, {DateTime? now}) {
    final minutes = habit.schedule.reminderMinutes;
    if (minutes == null) return null;
    final base = now ?? DateTime.now();
    final today = base.dayOnly;

    for (var i = 0; i < 14; i++) {
      final date = today.add(Duration(days: i));
      if (!habit.schedule.shouldDoOn(date)) continue;
      final candidate = DateTime(
        date.year,
        date.month,
        date.day,
        minutes ~/ 60,
        minutes % 60,
      );
      if (candidate.isAfter(base)) return candidate;
    }
    return null;
  }

  /// Upcoming reminders across all active habits, soonest first.
  static List<UpcomingReminder> upcoming(
    List<Habit> habits, {
    DateTime? now,
    int limit = 10,
  }) {
    final reminders = <UpcomingReminder>[];
    for (final habit in habits) {
      if (habit.isArchived) continue;
      final at = nextFor(habit, now: now);
      if (at == null) continue;
      reminders.add(
        UpcomingReminder(
          habitId: habit.id,
          habitName: habit.name,
          emoji: habit.emoji,
          at: at,
        ),
      );
    }
    reminders.sort((a, b) => a.at.compareTo(b.at));
    return reminders.take(limit).toList();
  }
}
