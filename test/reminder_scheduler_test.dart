import 'package:flutter_test/flutter_test.dart';
import 'package:habit_genius/data/models/habit.dart';
import 'package:habit_genius/features/habits/application/reminder_scheduler.dart';

Habit habit({
  int? reminderMinutes,
  Set<Weekday> weekdays = const {},
  int intervalDays = 1,
}) {
  return Habit(
    id: 'h1',
    name: 'Read',
    progressType: HabitProgressType.checkbox,
    createdAt: DateTime(2026),
    progressByDate: const {},
    schedule: HabitSchedule(
      reminderMinutes: reminderMinutes,
      weekdays: weekdays,
      intervalDays: intervalDays,
    ),
  );
}

void main() {
  final now = DateTime(2026, 10, 23, 9, 30);

  test('returns null without reminder time', () {
    expect(ReminderScheduler.nextFor(habit(), now: now), isNull);
  });

  test('schedules later today when time has not passed', () {
    final next = ReminderScheduler.nextFor(
      habit(reminderMinutes: 10 * 60),
      now: now,
    );
    expect(next, DateTime(2026, 10, 23, 10));
  });

  test('rolls to tomorrow when time has passed', () {
    final next = ReminderScheduler.nextFor(
      habit(reminderMinutes: 8 * 60),
      now: now,
    );
    expect(next, DateTime(2026, 10, 24, 8));
  });

  test('respects weekday schedules', () {
    // 2026-10-23 is a Friday; request Monday only.
    final next = ReminderScheduler.nextFor(
      habit(
        reminderMinutes: 8 * 60,
        weekdays: const {Weekday.monday},
      ),
      now: now,
    );
    expect(next?.weekday, DateTime.monday);
  });

  test('upcoming sorts reminders by time', () {
    final morning = habit(reminderMinutes: 8 * 60).copyWith(id: 'a');
    final evening = habit(reminderMinutes: 20 * 60).copyWith(id: 'b');
    final list = ReminderScheduler.upcoming([evening, morning], now: now);
    expect(list.map((r) => r.habitId).toList(), ['b', 'a']);
  });
}
