import 'package:flutter/foundation.dart';

import '../../../core/utils/date_x.dart';
import '../../../data/models/habit.dart';

@immutable
class HabitStreakMetrics {
  const HabitStreakMetrics({
    required this.currentStreak,
    required this.longestStreak,
    required this.totalCompletions,
    required this.completionRate7Days,
    required this.completionRate30Days,
    required this.geniusScore,
  });

  final int currentStreak;
  final int longestStreak;
  final int totalCompletions;
  final double completionRate7Days;
  final double completionRate30Days;
  final double geniusScore;

  static const empty = HabitStreakMetrics(
    currentStreak: 0,
    longestStreak: 0,
    totalCompletions: 0,
    completionRate7Days: 0,
    completionRate30Days: 0,
    geniusScore: 0,
  );
}

/// Streak, consistency and Genius Score calculations.
class StreakEngine {
  StreakEngine._();

  /// Consecutive completed days up to [from] (defaults to today).
  ///
  /// An unticked current day does not break the streak. [freezeDays] allows
  /// that many missed days inside the streak without breaking it.
  static int currentStreak(Habit habit, {DateTime? from, int freezeDays = 0}) {
    final end = (from ?? DateTime.now()).dayOnly;
    var cursor = end;
    var count = 0;
    var freezesLeft = freezeDays;

    // Today not done yet: don't break the chain.
    if (!habit.isCompletedOn(cursor)) {
      cursor = cursor.subtract(const Duration(days: 1));
    }

    while (true) {
      if (habit.isCompletedOn(cursor)) {
        count++;
      } else if (freezesLeft > 0) {
        freezesLeft--;
      } else {
        break;
      }
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return count;
  }

  /// Longest run of completed days in the habit's history.
  static int longestStreak(Habit habit, {int freezeDays = 0}) {
    final completedDates = habit.progressByDate.keys
        .map(DateTime.tryParse)
        .whereType<DateTime>()
        .where(habit.isCompletedOn)
        .map((d) => d.dayOnly)
        .toSet()
        .toList()
      ..sort();
    if (completedDates.isEmpty) return 0;

    var longest = 1;
    var current = 1;
    var previous = completedDates.first;

    for (var i = 1; i < completedDates.length; i++) {
      final date = completedDates[i];
      final gap = date.difference(previous).inDays;
      if (gap == 1) {
        current++;
      } else if (gap - 1 <= freezeDays) {
        current += gap;
      } else {
        current = 1;
      }
      if (current > longest) longest = current;
      previous = date;
    }
    return longest;
  }

  /// Share of completed days in the last [days] days.
  static double completionRate(Habit habit, {int days = 30, DateTime? from}) {
    if (days <= 0) return 0;
    final end = (from ?? DateTime.now()).dayOnly;
    var completed = 0;
    var scheduled = 0;
    for (var i = 0; i < days; i++) {
      final date = end.subtract(Duration(days: i));
      if (!habit.schedule.shouldDoOn(date)) continue;
      scheduled++;
      if (habit.isCompletedOn(date)) completed++;
    }
    if (scheduled == 0) return 0;
    return completed / scheduled;
  }

  /// Habit Genius score in the `0..100` range.
  ///
  /// Weights: current streak (30), longest streak (20), 30-day consistency
  /// (30), 7-day consistency (20).
  static double geniusScore(Habit habit, {DateTime? from}) {
    final current = currentStreak(habit, from: from);
    final longest = longestStreak(habit);
    final rate30 = completionRate(habit, days: 30, from: from);
    final rate7 = completionRate(habit, days: 7, from: from);

    final score = (current.clamp(0, 30) / 30) * 30 +
        (longest.clamp(0, 100) / 100) * 20 +
        rate30 * 30 +
        rate7 * 20;
    return score.clamp(0.0, 100.0);
  }

  static HabitStreakMetrics metrics(Habit habit, {DateTime? from}) {
    final total = habit.progressByDate.keys
        .map(DateTime.tryParse)
        .whereType<DateTime>()
        .where(habit.isCompletedOn)
        .length;
    return HabitStreakMetrics(
      currentStreak: currentStreak(habit, from: from),
      longestStreak: longestStreak(habit),
      totalCompletions: total,
      completionRate7Days: completionRate(habit, days: 7, from: from),
      completionRate30Days: completionRate(habit, days: 30, from: from),
      geniusScore: geniusScore(habit, from: from),
    );
  }
}
