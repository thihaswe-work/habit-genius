import '../models/habit.dart';

/// Persistence contract for habits.
///
/// Reads are synchronous (a local database can serve them from memory) while
/// writes are asynchronous. This keeps the UI layer free of loading spinners
/// for simple reads while still allowing real disk I/O.
abstract interface class HabitRepository {
  /// Every habit, including archived ones.
  List<Habit> getAll();

  /// Habits that are currently being tracked.
  List<Habit> getActive();

  /// Creates or updates [habit].
  Future<void> upsert(Habit habit);

  /// Removes the habit with [id].
  Future<void> delete(String id);

  /// Records [value] completions for [habit] on [date].
  Future<void> setProgress(Habit habit, DateTime date, int value);

  /// Toggles the completion state of a checkbox habit on [date].
  Future<void> toggle(Habit habit, DateTime date);
}
