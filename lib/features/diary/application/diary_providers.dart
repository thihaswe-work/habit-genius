import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/date_x.dart';
import '../../../core/utils/iterable_x.dart';
import '../../../core/utils/id_x.dart';
import '../../../data/models/diary_entry.dart';
import '../../../data/repositories/repository_providers.dart';

/// All diary entries, newest first.
final diaryEntriesProvider =
    NotifierProvider<DiaryEntriesNotifier, List<DiaryEntry>>(
  DiaryEntriesNotifier.new,
);

/// The entry written today, if any.
final todayDiaryProvider = Provider<DiaryEntry?>((Ref ref) {
  final entries = ref.watch(diaryEntriesProvider);
  final today = DateTime.now();
  return entries.firstWhereOrNull((DiaryEntry e) => e.date.isSameDay(today));
});

/// The most recent entry, regardless of the day it was written.
final latestDiaryProvider = Provider<DiaryEntry?>((Ref ref) {
  final entries = ref.watch(diaryEntriesProvider);
  return entries.isEmpty ? null : entries.first;
});

/// Manages diary entries.
class DiaryEntriesNotifier extends Notifier<List<DiaryEntry>> {
  @override
  List<DiaryEntry> build() => ref.read(diaryRepositoryProvider).getAll();

  /// Creates or updates today's entry.
  Future<void> writeToday({required String title, required String content}) async {
    final repository = ref.read(diaryRepositoryProvider);
    final now = DateTime.now();
    final existing = repository.entryFor(now);
    final entry = DiaryEntry(
      id: existing?.id ?? newId(),
      date: now,
      title: title.trim(),
      content: content,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );
    await repository.save(entry);
    state = repository.getAll();
  }

  /// Removes an entry.
  Future<void> delete(String id) async {
    final repository = ref.read(diaryRepositoryProvider);
    await repository.delete(id);
    state = repository.getAll();
  }
}
