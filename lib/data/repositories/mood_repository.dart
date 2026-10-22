import '../models/mood_entry.dart';

/// Persistence contract for mood logs.
abstract interface class MoodRepository {
  /// All mood entries, newest first.
  List<MoodEntry> getAll();

  /// The entry logged on [date], if any.
  MoodEntry? entryFor(DateTime date);

  /// Creates or updates [entry].
  Future<void> save(MoodEntry entry);

  /// Removes the entry with [id].
  Future<void> delete(String id);
}
