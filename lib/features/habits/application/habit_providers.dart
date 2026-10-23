import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/habit.dart';
import '../../../data/repositories/habit_repository.dart';
import '../../../data/repositories/repository_providers.dart';

/// The habits currently being tracked.
final habitsProvider =
    NotifierProvider<HabitsNotifier, List<Habit>>(HabitsNotifier.new);

/// Habits scheduled for today, honouring weekday/interval schedules.
final todayHabitsProvider = Provider<List<Habit>>((Ref ref) {
  final habits = ref.watch(habitsProvider);
  final today = DateTime.now();
  return habits
      .where((Habit h) => !h.isArchived && h.schedule.shouldDoOn(today))
      .toList();
});

/// How many of today's scheduled habits are already complete.
final habitCompletionProvider = Provider<({int done, int total})>((Ref ref) {
  final habits = ref.watch(todayHabitsProvider);
  final today = DateTime.now();
  final done = habits.where((Habit h) => h.isCompletedOn(today)).length;
  return (done: done, total: habits.length);
});

/// Manages habit state and writes progress back to the repository.
class HabitsNotifier extends Notifier<List<Habit>> {
  HabitRepository get _repository => ref.read(habitRepositoryProvider);

  @override
  List<Habit> build() => _repository.getActive();

  /// Toggles a checkbox habit for [date].
  Future<void> toggle(Habit habit, DateTime date) async {
    await _repository.toggle(habit, date);
    state = _repository.getActive();
  }

  /// Adds one completion to a counter habit.
  Future<void> increment(Habit habit, DateTime date) async {
    final current = habit.progressOn(date);
    await _repository.setProgress(habit, date, current + 1);
    state = _repository.getActive();
  }

  /// Removes one completion from a counter habit.
  Future<void> decrement(Habit habit, DateTime date) async {
    final current = habit.progressOn(date);
    await _repository.setProgress(habit, date, current - 1);
    state = _repository.getActive();
  }

  /// Adds [minutes] of tracked time to a duration habit.
  Future<void> addMinutes(Habit habit, DateTime date, int minutes) async {
    final current = habit.progressOn(date);
    final next = (current + minutes).clamp(0, habit.effectiveTarget);
    await _repository.setProgress(habit, date, next);
    state = _repository.getActive();
  }

  /// Sets the tracked time of a duration habit (used by the timer sheet).
  Future<void> setProgress(
    Habit habit,
    DateTime date,
    int value,
  ) async {
    await _repository.setProgress(habit, date, value);
    state = _repository.getActive();
  }

  /// Creates or updates a habit.
  Future<void> upsert(Habit habit) async {
    await _repository.upsert(habit);
    state = _repository.getActive();
  }

  /// Archives (or restores) a habit.
  Future<void> setArchived(Habit habit, bool archived) async {
    await _repository.upsert(habit.copyWith(isArchived: archived));
    state = _repository.getActive();
  }

  /// Deletes a habit permanently.
  Future<void> delete(String id) async {
    await _repository.delete(id);
    state = _repository.getActive();
  }
}
