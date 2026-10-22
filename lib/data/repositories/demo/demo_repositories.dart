import '../../../core/utils/date_x.dart';
import '../../models/diary_entry.dart';
import '../../models/expense_entry.dart';
import '../../models/focus_session.dart';
import '../../models/habit.dart';
import '../../models/mood_entry.dart';
import '../diary_repository.dart';
import '../expense_repository.dart';
import '../focus_repository.dart';
import '../habit_repository.dart';
import '../mood_repository.dart';
import 'demo_data.dart';

/// In-memory habit store used until the Hive implementation lands.
class DemoHabitRepository implements HabitRepository {
  DemoHabitRepository() : _habits = DemoData.habits();

  final List<Habit> _habits;

  @override
  List<Habit> getAll() => List<Habit>.unmodifiable(_habits);

  @override
  List<Habit> getActive() =>
      List<Habit>.unmodifiable(_habits.where((Habit h) => !h.isArchived));

  @override
  Future<void> upsert(Habit habit) async {
    final index = _habits.indexWhere((Habit h) => h.id == habit.id);
    if (index == -1) {
      _habits.add(habit);
    } else {
      _habits[index] = habit;
    }
  }

  @override
  Future<void> delete(String id) async {
    _habits.removeWhere((Habit h) => h.id == id);
  }

  @override
  Future<void> setProgress(Habit habit, DateTime date, int value) async {
    final progress = Map<String, int>.from(habit.progressByDate);
    final key = date.dayKey;
    if (value <= 0) {
      progress.remove(key);
    } else {
      progress[key] = value;
    }
    await upsert(habit.copyWith(progressByDate: progress));
  }

  @override
  Future<void> toggle(Habit habit, DateTime date) async {
    final current = habit.progressOn(date);
    await setProgress(habit, date, current > 0 ? 0 : 1);
  }
}

/// In-memory mood store.
class DemoMoodRepository implements MoodRepository {
  DemoMoodRepository() : _entries = DemoData.moods();

  final List<MoodEntry> _entries;

  @override
  List<MoodEntry> getAll() {
    final sorted = List<MoodEntry>.from(_entries)
      ..sort((MoodEntry a, MoodEntry b) => b.date.compareTo(a.date));
    return List<MoodEntry>.unmodifiable(sorted);
  }

  @override
  MoodEntry? entryFor(DateTime date) {
    for (final entry in _entries) {
      if (entry.date.isSameDay(date)) return entry;
    }
    return null;
  }

  @override
  Future<void> save(MoodEntry entry) async {
    final index = _entries.indexWhere((MoodEntry e) => e.id == entry.id);
    if (index == -1) {
      _entries.add(entry);
    } else {
      _entries[index] = entry;
    }
  }

  @override
  Future<void> delete(String id) async {
    _entries.removeWhere((MoodEntry e) => e.id == id);
  }
}

/// In-memory expense store.
class DemoExpenseRepository implements ExpenseRepository {
  DemoExpenseRepository() : _entries = DemoData.expenses();

  final List<ExpenseEntry> _entries;

  @override
  List<ExpenseEntry> getAll() {
    final sorted = List<ExpenseEntry>.from(_entries)
      ..sort((ExpenseEntry a, ExpenseEntry b) => b.date.compareTo(a.date));
    return List<ExpenseEntry>.unmodifiable(sorted);
  }

  @override
  Future<void> add(ExpenseEntry entry) async => _entries.add(entry);

  @override
  Future<void> update(ExpenseEntry entry) async {
    final index = _entries.indexWhere((ExpenseEntry e) => e.id == entry.id);
    if (index != -1) _entries[index] = entry;
  }

  @override
  Future<void> delete(String id) async {
    _entries.removeWhere((ExpenseEntry e) => e.id == id);
  }
}

/// In-memory focus-session store.
class DemoFocusRepository implements FocusRepository {
  DemoFocusRepository() : _sessions = DemoData.focusSessions();

  final List<FocusSession> _sessions;

  @override
  List<FocusSession> getAll() {
    final sorted = List<FocusSession>.from(_sessions)
      ..sort(
        (FocusSession a, FocusSession b) => b.startedAt.compareTo(a.startedAt),
      );
    return List<FocusSession>.unmodifiable(sorted);
  }

  @override
  Future<void> save(FocusSession session) async {
    final index = _sessions.indexWhere((FocusSession s) => s.id == session.id);
    if (index == -1) {
      _sessions.add(session);
    } else {
      _sessions[index] = session;
    }
  }

  @override
  Future<void> delete(String id) async {
    _sessions.removeWhere((FocusSession s) => s.id == id);
  }

  @override
  int focusedMinutesOn(DateTime date) => _sessions
      .where((FocusSession s) => s.startedAt.isSameDay(date))
      .fold<int>(0, (int sum, FocusSession s) => sum + s.focusedMinutes);
}

/// In-memory diary store.
class DemoDiaryRepository implements DiaryRepository {
  DemoDiaryRepository() : _entries = DemoData.diaryEntries();

  final List<DiaryEntry> _entries;

  @override
  List<DiaryEntry> getAll() {
    final sorted = List<DiaryEntry>.from(_entries)
      ..sort((DiaryEntry a, DiaryEntry b) => b.date.compareTo(a.date));
    return List<DiaryEntry>.unmodifiable(sorted);
  }

  @override
  DiaryEntry? entryFor(DateTime date) {
    for (final entry in _entries) {
      if (entry.date.isSameDay(date)) return entry;
    }
    return null;
  }

  @override
  Future<void> save(DiaryEntry entry) async {
    final index = _entries.indexWhere((DiaryEntry e) => e.id == entry.id);
    if (index == -1) {
      _entries.add(entry);
    } else {
      _entries[index] = entry;
    }
  }

  @override
  Future<void> delete(String id) async {
    _entries.removeWhere((DiaryEntry e) => e.id == id);
  }
}
