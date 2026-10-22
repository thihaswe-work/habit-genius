import 'package:flutter_test/flutter_test.dart';
import 'package:habit_genius/core/utils/date_x.dart';
import 'package:habit_genius/data/backup/backup_service.dart';
import 'package:habit_genius/data/models/diary_entry.dart';
import 'package:habit_genius/data/models/expense_entry.dart';
import 'package:habit_genius/data/models/focus_session.dart';
import 'package:habit_genius/data/models/habit.dart';
import 'package:habit_genius/data/models/mood_entry.dart';
import 'package:habit_genius/data/repositories/diary_repository.dart';
import 'package:habit_genius/data/repositories/expense_repository.dart';
import 'package:habit_genius/data/repositories/focus_repository.dart';
import 'package:habit_genius/data/repositories/habit_repository.dart';
import 'package:habit_genius/data/repositories/mood_repository.dart';

void main() {
  final date = DateTime(2026, 10, 20, 9, 30);

  group('BackupService', () {
    test('round-trips every module', () async {
      final source = _Repositories.seeded(date);
      final json = _service(source).exportJson();
      final target = _Repositories();

      final summary = await _service(target).importJson(json);

      expect(summary.habits, 1);
      expect(summary.moods, 1);
      expect(summary.expenses, 1);
      expect(summary.focusSessions, 1);
      expect(summary.diary, 1);
      expect(summary.total, 5);

      final habit = target.habits.getAll().single;
      expect(habit.name, 'Read');
      expect(habit.progressByDate[date.dayKey], 2);

      expect(target.moods.getAll().single.mood, Mood.good);
      expect(target.expenses.getAll().single.amount, 12.5);
      expect(target.focusSessions.getAll().single.focusedMinutes, 25);
      expect(target.diary.getAll().single.title, 'Day');
    });

    test('merge keeps unrelated records and updates matching ids', () async {
      final target = _Repositories(
        habits: <Habit>[
          _habit(id: 'habit-1', name: 'Old name', createdAt: date),
          _habit(id: 'keep', name: 'Keep me', createdAt: date),
        ],
      );

      await _service(
        target,
      ).importJson(_service(_Repositories.seeded(date)).exportJson());

      final habits = target.habits.getAll();
      expect(habits, hasLength(2));
      expect(habits.firstWhere((Habit h) => h.id == 'habit-1').name, 'Read');
      expect(habits.any((Habit h) => h.id == 'keep'), isTrue);
    });

    test('replace removes records that are not in the backup', () async {
      final target = _Repositories(
        habits: <Habit>[_habit(id: 'keep', name: 'Keep me', createdAt: date)],
      );

      await _service(target).importJson(
        _service(_Repositories.seeded(date)).exportJson(),
        replace: true,
      );

      final habits = target.habits.getAll();
      expect(habits, hasLength(1));
      expect(habits.single.id, 'habit-1');
    });

    test('a malformed file does not erase existing data', () async {
      final target = _Repositories(
        habits: <Habit>[_habit(id: 'keep', name: 'Keep me', createdAt: date)],
      );

      await expectLater(
        _service(target).importJson('not a backup', replace: true),
        throwsFormatException,
      );

      expect(target.habits.getAll(), hasLength(1));
    });
  });
}

BackupService _service(_Repositories repositories) {
  return BackupService(
    habits: repositories.habits,
    moods: repositories.moods,
    expenses: repositories.expenses,
    focusSessions: repositories.focusSessions,
    diary: repositories.diary,
  );
}

Habit _habit({
  required String id,
  required String name,
  required DateTime createdAt,
  Map<String, int> progressByDate = const <String, int>{},
}) {
  return Habit(
    id: id,
    name: name,
    progressType: HabitProgressType.checkbox,
    createdAt: createdAt,
    progressByDate: progressByDate,
  );
}

class _Repositories {
  _Repositories({
    List<Habit> habits = const <Habit>[],
    List<MoodEntry> moods = const <MoodEntry>[],
    List<ExpenseEntry> expenses = const <ExpenseEntry>[],
    List<FocusSession> focusSessions = const <FocusSession>[],
    List<DiaryEntry> diary = const <DiaryEntry>[],
  }) : habits = _FakeHabitRepository(habits),
       moods = _FakeMoodRepository(moods),
       expenses = _FakeExpenseRepository(expenses),
       focusSessions = _FakeFocusRepository(focusSessions),
       diary = _FakeDiaryRepository(diary);

  factory _Repositories.seeded(DateTime date) {
    return _Repositories(
      habits: <Habit>[
        Habit(
          id: 'habit-1',
          name: 'Read',
          progressType: HabitProgressType.counter,
          target: 3,
          unit: 'pages',
          createdAt: date,
          progressByDate: <String, int>{date.dayKey: 2},
        ),
      ],
      moods: <MoodEntry>[
        MoodEntry(id: 'mood-1', date: date, mood: Mood.good, note: 'ok'),
      ],
      expenses: <ExpenseEntry>[
        ExpenseEntry(
          id: 'expense-1',
          date: date,
          amount: 12.5,
          type: TransactionType.expense,
          category: ExpenseCategory.food,
          note: 'lunch',
        ),
      ],
      focusSessions: <FocusSession>[
        FocusSession(
          id: 'focus-1',
          startedAt: date,
          plannedMinutes: 25,
          focusedMinutes: 25,
          completed: true,
          label: 'work',
        ),
      ],
      diary: <DiaryEntry>[
        DiaryEntry(
          id: 'diary-1',
          date: date,
          title: 'Day',
          content: 'Wrote things',
          createdAt: date,
          updatedAt: date,
        ),
      ],
    );
  }

  final _FakeHabitRepository habits;
  final _FakeMoodRepository moods;
  final _FakeExpenseRepository expenses;
  final _FakeFocusRepository focusSessions;
  final _FakeDiaryRepository diary;
}

class _FakeHabitRepository implements HabitRepository {
  _FakeHabitRepository(Iterable<Habit> initial) : _items = <Habit>[...initial];

  final List<Habit> _items;

  @override
  List<Habit> getAll() => List<Habit>.unmodifiable(_items);

  @override
  List<Habit> getActive() => _items.where((Habit h) => !h.isArchived).toList();

  @override
  Future<void> upsert(Habit habit) async {
    final index = _items.indexWhere((Habit h) => h.id == habit.id);
    if (index == -1) {
      _items.add(habit);
    } else {
      _items[index] = habit;
    }
  }

  @override
  Future<void> delete(String id) async {
    _items.removeWhere((Habit h) => h.id == id);
  }

  @override
  Future<void> setProgress(Habit habit, DateTime date, int value) async {
    final progress = Map<String, int>.from(habit.progressByDate);
    if (value <= 0) {
      progress.remove(date.dayKey);
    } else {
      progress[date.dayKey] = value;
    }
    await upsert(habit.copyWith(progressByDate: progress));
  }

  @override
  Future<void> toggle(Habit habit, DateTime date) async {
    await setProgress(habit, date, habit.progressOn(date) > 0 ? 0 : 1);
  }
}

class _FakeMoodRepository implements MoodRepository {
  _FakeMoodRepository(Iterable<MoodEntry> initial)
    : _items = <MoodEntry>[...initial];

  final List<MoodEntry> _items;

  @override
  List<MoodEntry> getAll() => List<MoodEntry>.unmodifiable(_items);

  @override
  MoodEntry? entryFor(DateTime date) {
    for (final entry in _items) {
      if (entry.date.isSameDay(date)) return entry;
    }
    return null;
  }

  @override
  Future<void> save(MoodEntry entry) async {
    final index = _items.indexWhere((MoodEntry e) => e.id == entry.id);
    if (index == -1) {
      _items.add(entry);
    } else {
      _items[index] = entry;
    }
  }

  @override
  Future<void> delete(String id) async {
    _items.removeWhere((MoodEntry e) => e.id == id);
  }
}

class _FakeExpenseRepository implements ExpenseRepository {
  _FakeExpenseRepository(Iterable<ExpenseEntry> initial)
    : _items = <ExpenseEntry>[...initial];

  final List<ExpenseEntry> _items;

  @override
  List<ExpenseEntry> getAll() => List<ExpenseEntry>.unmodifiable(_items);

  @override
  Future<void> add(ExpenseEntry entry) async {
    _items.add(entry);
  }

  @override
  Future<void> update(ExpenseEntry entry) async {
    final index = _items.indexWhere((ExpenseEntry e) => e.id == entry.id);
    if (index != -1) _items[index] = entry;
  }

  @override
  Future<void> delete(String id) async {
    _items.removeWhere((ExpenseEntry e) => e.id == id);
  }
}

class _FakeFocusRepository implements FocusRepository {
  _FakeFocusRepository(Iterable<FocusSession> initial)
    : _items = <FocusSession>[...initial];

  final List<FocusSession> _items;

  @override
  List<FocusSession> getAll() => List<FocusSession>.unmodifiable(_items);

  @override
  Future<void> save(FocusSession session) async {
    final index = _items.indexWhere((FocusSession s) => s.id == session.id);
    if (index == -1) {
      _items.add(session);
    } else {
      _items[index] = session;
    }
  }

  @override
  Future<void> delete(String id) async {
    _items.removeWhere((FocusSession s) => s.id == id);
  }

  @override
  int focusedMinutesOn(DateTime date) => _items
      .where((FocusSession s) => s.startedAt.isSameDay(date))
      .fold<int>(0, (int sum, FocusSession s) => sum + s.focusedMinutes);
}

class _FakeDiaryRepository implements DiaryRepository {
  _FakeDiaryRepository(Iterable<DiaryEntry> initial)
    : _items = <DiaryEntry>[...initial];

  final List<DiaryEntry> _items;

  @override
  List<DiaryEntry> getAll() => List<DiaryEntry>.unmodifiable(_items);

  @override
  DiaryEntry? entryFor(DateTime date) {
    for (final entry in _items) {
      if (entry.date.isSameDay(date)) return entry;
    }
    return null;
  }

  @override
  Future<void> save(DiaryEntry entry) async {
    final index = _items.indexWhere((DiaryEntry e) => e.id == entry.id);
    if (index == -1) {
      _items.add(entry);
    } else {
      _items[index] = entry;
    }
  }

  @override
  Future<void> delete(String id) async {
    _items.removeWhere((DiaryEntry e) => e.id == id);
  }
}
