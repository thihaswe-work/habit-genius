import '../models/diary_entry.dart';

/// Persistence contract for diary entries.
abstract interface class DiaryRepository {
  /// All entries, newest first.
  List<DiaryEntry> getAll();

  /// The entry written on [date], if any.
  DiaryEntry? entryFor(DateTime date);

  /// Creates or updates [entry].
  Future<void> save(DiaryEntry entry);

  /// Removes the entry with [id].
  Future<void> delete(String id);
}
