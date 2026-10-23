import 'package:flutter_test/flutter_test.dart';
import 'package:habit_genius/data/models/habit.dart';
import 'package:habit_genius/features/habits/application/streak_engine.dart';

Habit habitWith(Map<String, int> progress, {HabitProgressKind? kind}) {
  return Habit(
    id: 'h1',
    name: 'Test',
    progressType: kind == HabitProgressKind.checkbox
        ? HabitProgressType.checkbox
        : HabitProgressType.counter,
    progressKind: kind,
    target: 1,
    createdAt: DateTime(2026),
    progressByDate: progress,
  );
}

String key(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

void main() {
  final today = DateTime(2026, 10, 23);

  group('currentStreak', () {
    test('counts consecutive completed days', () {
      final habit = habitWith({
        key(today): 1,
        key(today.subtract(const Duration(days: 1))): 1,
        key(today.subtract(const Duration(days: 2))): 1,
      });
      expect(StreakEngine.currentStreak(habit, from: today), 3);
    });

    test('unticked today keeps yesterday streak alive', () {
      final habit = habitWith({
        key(today.subtract(const Duration(days: 1))): 1,
        key(today.subtract(const Duration(days: 2))): 1,
      });
      expect(StreakEngine.currentStreak(habit, from: today), 2);
    });

    test('broken chain stops the count', () {
      final habit = habitWith({
        key(today): 1,
        key(today.subtract(const Duration(days: 2))): 1,
      });
      expect(StreakEngine.currentStreak(habit, from: today), 1);
    });

    test('freeze day bridges a missed day', () {
      final habit = habitWith({
        key(today): 1,
        key(today.subtract(const Duration(days: 2))): 1,
        key(today.subtract(const Duration(days: 3))): 1,
      });
      expect(
        StreakEngine.currentStreak(habit, from: today, freezeDays: 1),
        3,
      );
    });
  });

  group('longestStreak', () {
    test('finds the longest historical run', () {
      final start = DateTime(2026, 9, 1);
      final habit = habitWith({
        for (var i = 0; i < 5; i++) key(start.add(Duration(days: i))): 1,
        for (var i = 10; i < 13; i++) key(start.add(Duration(days: i))): 1,
      });
      expect(StreakEngine.longestStreak(habit), 5);
    });

    test('returns zero without completions', () {
      expect(StreakEngine.longestStreak(habitWith({})), 0);
    });
  });

  group('completionRate / score', () {
    test('completion rate is 1 for full period', () {
      final habit = habitWith({
        for (var i = 0; i < 30; i++) key(today.subtract(Duration(days: i))): 1,
      });
      expect(
        StreakEngine.completionRate(habit, days: 30, from: today),
        closeTo(1, 0.001),
      );
    });

    test('genius score stays within 0..100', () {
      final habit = habitWith({
        for (var i = 0; i < 5; i++) key(today.subtract(Duration(days: i))): 1,
      });
      final score = StreakEngine.geniusScore(habit, from: today);
      expect(score, greaterThan(0));
      expect(score, lessThanOrEqualTo(100));
    });
  });

  group('duration habits', () {
    test('completion requires the target minutes', () {
      final habit = Habit(
        id: 'd1',
        name: 'Meditate',
        progressType: HabitProgressType.counter,
        progressKind: HabitProgressKind.duration,
        durationMinutesTarget: 10,
        createdAt: DateTime(2026),
        progressByDate: {key(today): 9},
      );
      expect(habit.isCompletedOn(today), isFalse);
      expect(
        habit.copyWith(
          progressByDate: {key(today): 10},
        ).isCompletedOn(today),
        isTrue,
      );
    });
  });

  group('JSON back-compat', () {
    test('old payload without new fields still parses', () {
      final habit = HabitJson.fromJson({
        'id': 'legacy',
        'name': 'Legacy',
        'emoji': '📚',
        'progressType': 0,
        'target': 1,
        'unit': null,
        'createdAt': '2026-01-01T00:00:00.000',
        'progressByDate': {'2026-01-01': 1},
        'isArchived': false,
      });
      expect(habit.id, 'legacy');
      expect(habit.kind, HabitProgressKind.checkbox);
      expect(habit.schedule.intervalDays, 1);
      expect(habit.durationMinutesTarget, 0);
    });

    test('round trips new fields', () {
      final habit = Habit(
        id: 'n1',
        name: 'Water',
        progressType: HabitProgressType.counter,
        progressKind: HabitProgressKind.counter,
        target: 8,
        unit: 'glasses',
        createdAt: DateTime(2026, 1, 1),
        schedule: const HabitSchedule(
          timeOfDay: TimeOfDayFilter.morning,
          weekdays: {Weekday.monday, Weekday.friday},
          reminderMinutes: 480,
        ),
        progressByDate: const {},
      );
      final decoded = HabitJson.fromJson(habit.toJson());
      expect(decoded.schedule.timeOfDay, TimeOfDayFilter.morning);
      expect(decoded.schedule.weekdays, {Weekday.monday, Weekday.friday});
      expect(decoded.schedule.reminderMinutes, 480);
      expect(decoded.unit, 'glasses');
    });
  });
}
