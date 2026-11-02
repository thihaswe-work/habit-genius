import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/date_x.dart';
import '../../../core/utils/iterable_x.dart';
import '../../../core/utils/id_x.dart';
import '../../../data/models/mood_entry.dart';
import '../../../data/repositories/repository_providers.dart';

/// All mood entries, newest first.
final moodEntriesProvider =
    NotifierProvider<MoodEntriesNotifier, List<MoodEntry>>(
  MoodEntriesNotifier.new,
);

/// The mood logged today, if the user has already checked in.
final todayMoodProvider = Provider<MoodEntry?>((Ref ref) {
  final entries = ref.watch(moodEntriesProvider);
  final today = DateTime.now();
  return entries.firstWhereOrNull((MoodEntry e) => e.date.isSameDay(today));
});

/// Average mood score over the last seven days.
final moodAverageProvider = Provider<double?>((Ref ref) {
  final entries = ref.watch(moodEntriesProvider);
  final cutoff = DateTime.now().subtract(const Duration(days: 7));
  final recent = entries.where((MoodEntry e) => e.date.isAfter(cutoff)).toList();
  if (recent.isEmpty) return null;
  final total = recent.fold<int>(0, (int sum, MoodEntry e) => sum + e.mood.score);
  return total / recent.length;
});

/// Manages mood logs.
class MoodEntriesNotifier extends Notifier<List<MoodEntry>> {
  @override
  List<MoodEntry> build() => ref.read(moodRepositoryProvider).getAll();

  /// Logs (or replaces) today's mood.
  Future<void> logMood(Mood mood, {String? note}) async {
    final repository = ref.read(moodRepositoryProvider);
    final now = DateTime.now();
    final existing = repository.entryFor(now);
    final entry = MoodEntry(
      id: existing?.id ?? newId(),
      date: now,
      mood: mood,
      note: note,
    );
    await repository.save(entry);
    state = repository.getAll();
  }

  /// Removes a mood entry.
  Future<void> delete(String id) async {
    final repository = ref.read(moodRepositoryProvider);
    await repository.delete(id);
    state = repository.getAll();
  }
}
