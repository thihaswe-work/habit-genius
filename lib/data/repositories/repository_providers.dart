import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../local/hive_service.dart';
import '../local/repositories/hive_habit_repository.dart';
import '../local/repositories/hive_mood_repository.dart';
import '../local/repositories/hive_focus_repository.dart';
import '../local/repositories/hive_expense_repository.dart';
import '../local/repositories/hive_diary_repository.dart';
import '../models/diary_entry.dart';
import '../models/expense_entry.dart';
import '../models/focus_session.dart';
import '../models/mood_entry.dart';
import 'diary_repository.dart';
import 'expense_repository.dart';
import 'focus_repository.dart';
import 'habit_repository.dart';
import 'mood_repository.dart';
import '../models/habit.dart';

final habitRepositoryProvider = Provider<HabitRepository>((Ref ref) {
  if (!HiveService.isReady) {
    return _InMemoryHabitRepo();
  }
  try {
    final box = HiveService.instance.box('habits');
    return HiveHabitRepository(box);
  } catch (_) {
    return _InMemoryHabitRepo();
  }
});

final moodRepositoryProvider = Provider<MoodRepository>((Ref ref) {
  if (!HiveService.isReady) {
    return _InMemoryMoodRepo();
  }
  try {
    final box = HiveService.instance.box('moods');
    return HiveMoodRepository(box);
  } catch (_) {
    return _InMemoryMoodRepo();
  }
});

final expenseRepositoryProvider = Provider<ExpenseRepository>((Ref ref) {
  if (!HiveService.isReady) {
    return _InMemoryExpenseRepo();
  }
  try {
    final box = HiveService.instance.box('expenses');
    return HiveExpenseRepository(box);
  } catch (_) {
    return _InMemoryExpenseRepo();
  }
});

final focusRepositoryProvider = Provider<FocusRepository>((Ref ref) {
  if (!HiveService.isReady) {
    return _InMemoryFocusRepo();
  }
  try {
    final box = HiveService.instance.box('focus_sessions');
    return HiveFocusRepository(box);
  } catch (_) {
    return _InMemoryFocusRepo();
  }
});

final diaryRepositoryProvider = Provider<DiaryRepository>((Ref ref) {
  if (!HiveService.isReady) {
    return _InMemoryDiaryRepo();
  }
  try {
    final box = HiveService.instance.box('diary');
    return HiveDiaryRepository(box);
  } catch (_) {
    return _InMemoryDiaryRepo();
  }
});

class _InMemoryMoodRepo implements MoodRepository {
  final List<MoodEntry> items = [];
  @override
  List<MoodEntry> getAll() => List<MoodEntry>.unmodifiable(items);
  @override
  MoodEntry? entryFor(DateTime date) => null;
  @override
  Future<void> save(MoodEntry item) async {}
  @override
  Future<void> delete(String id) async {}
}

class _InMemoryExpenseRepo implements ExpenseRepository {
  final List<ExpenseEntry> items = [];
  @override
  List<ExpenseEntry> getAll() => List<ExpenseEntry>.unmodifiable(items);
  @override
  Future<void> add(ExpenseEntry item) async {}
  @override
  Future<void> update(ExpenseEntry item) async {}
  @override
  Future<void> delete(String id) async {}
}

class _InMemoryFocusRepo implements FocusRepository {
  final List<FocusSession> items = [];
  @override
  List<FocusSession> getAll() => List<FocusSession>.unmodifiable(items);
  @override
  Future<void> save(FocusSession item) async {}
  @override
  Future<void> delete(String id) async {}
  @override
  int focusedMinutesOn(DateTime date) => 0;
}

class _InMemoryDiaryRepo implements DiaryRepository {
  final List<DiaryEntry> items = [];
  @override
  List<DiaryEntry> getAll() => List<DiaryEntry>.unmodifiable(items);
  @override
  DiaryEntry? entryFor(DateTime date) => null;
  @override
  Future<void> save(DiaryEntry item) async {}
  @override
  Future<void> delete(String id) async {}
}



class _InMemoryHabitRepo implements HabitRepository {
  final List<Habit> items = [];
  @override
  List<Habit> getAll() => items;
  @override
  List<Habit> getActive() => items;
  @override
  Future<void> upsert(Habit habit) async {}
  @override
  Future<void> delete(String id) async {}
  @override
  Future<void> setProgress(Habit habit, DateTime date, int value) async {}
  @override
  Future<void> toggle(Habit habit, DateTime date) async {}
}
