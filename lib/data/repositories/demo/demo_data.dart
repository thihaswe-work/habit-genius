import '../../../core/utils/date_x.dart';
import '../../../core/utils/id_x.dart';
import '../../models/diary_entry.dart';
import '../../models/expense_entry.dart';
import '../../models/focus_session.dart';
import '../../models/habit.dart';
import '../../models/mood_entry.dart';

/// Seed data used by the in-memory repositories.
///
/// It exists so the dashboard can be built and reviewed against realistic
/// content. Each feature step replaces its demo repository with a
/// Hive-backed implementation behind the same interface.
abstract final class DemoData {
  static List<Habit> habits() {
    final now = DateTime.now();
    final today = now.dayOnly;

    final workout = Habit(
      id: newId(),
      name: 'Morning workout',
      emoji: '🏋️',
      progressType: HabitProgressType.checkbox,
      createdAt: today.subtract(const Duration(days: 30)),
      progressByDate: _lastDays(today, 5, <int>[1, 1, 0, 1, 1, 1, 0]),
    );

    final reading = Habit(
      id: newId(),
      name: 'Read pages',
      emoji: '📚',
      progressType: HabitProgressType.counter,
      target: 20,
      unit: 'pages',
      createdAt: today.subtract(const Duration(days: 30)),
      progressByDate: _lastDays(today, 5, <int>[20, 12, 20, 8, 20, 15, 6]),
    );

    final water = Habit(
      id: newId(),
      name: 'Drink water',
      emoji: '💧',
      progressType: HabitProgressType.counter,
      target: 8,
      unit: 'glasses',
      createdAt: today.subtract(const Duration(days: 30)),
      progressByDate: _lastDays(today, 5, <int>[8, 6, 8, 8, 5, 8, 4]),
    );

    final meditate = Habit(
      id: newId(),
      name: 'Meditate',
      emoji: '🧘',
      progressType: HabitProgressType.checkbox,
      createdAt: today.subtract(const Duration(days: 30)),
      progressByDate: _lastDays(today, 5, <int>[1, 0, 1, 1, 0, 1, 1]),
    );

    final screens = Habit(
      id: newId(),
      name: 'Screens off by 10pm',
      emoji: '🌙',
      progressType: HabitProgressType.checkbox,
      createdAt: today.subtract(const Duration(days: 30)),
      progressByDate: _lastDays(today, 5, <int>[0, 1, 1, 0, 1, 1, 0]),
    );

    return <Habit>[workout, reading, water, meditate, screens];
  }

  static List<MoodEntry> moods() {
    final today = DateTime.now().dayOnly;
    const feelings = <Mood>[
      Mood.good,
      Mood.great,
      Mood.okay,
      Mood.good,
      Mood.bad,
      Mood.great,
      Mood.okay,
    ];

    return List<MoodEntry>.generate(7, (int i) {
      final date = today.subtract(Duration(days: 6 - i));
      return MoodEntry(
        id: newId(),
        date: date.add(const Duration(hours: 21)),
        mood: feelings[i],
        note: i == feelings.length - 1 ? 'Productive day, kept the streak.' : null,
      );
    });
  }

  static List<ExpenseEntry> expenses() {
    final today = DateTime.now();
    final entries = <ExpenseEntry>[];

    void add(
      int daysAgo,
      double amount,
      TransactionType type,
      ExpenseCategory category,
      String note,
    ) {
      entries.add(
        ExpenseEntry(
          id: newId(),
          date: today.subtract(Duration(days: daysAgo, hours: 3)),
          amount: amount,
          type: type,
          category: category,
          note: note,
        ),
      );
    }

    add(0, 12.50, TransactionType.expense, ExpenseCategory.food, 'Lunch');
    add(0, 4.20, TransactionType.expense, ExpenseCategory.transport, 'Bus');
    add(1, 38.00, TransactionType.expense, ExpenseCategory.shopping, 'Running shoes');
    add(1, 64.90, TransactionType.expense, ExpenseCategory.bills, 'Internet + phone');
    add(2, 21.00, TransactionType.expense, ExpenseCategory.food, 'Groceries');
    add(3, 15.00, TransactionType.expense, ExpenseCategory.fun, 'Cinema');
    add(5, 2400.00, TransactionType.income, ExpenseCategory.salary, 'Salary');
    add(6, 9.99, TransactionType.expense, ExpenseCategory.fun, 'Music subscription');
    add(8, 45.30, TransactionType.expense, ExpenseCategory.health, 'Pharmacy');
    add(11, 28.75, TransactionType.expense, ExpenseCategory.food, 'Dinner');

    return entries;
  }

  static List<FocusSession> focusSessions() {
    final today = DateTime.now();

    return <FocusSession>[
      FocusSession(
        id: newId(),
        startedAt: today.subtract(const Duration(hours: 3)),
        plannedMinutes: 25,
        focusedMinutes: 25,
        completed: true,
        label: 'Dart refactor',
      ),
      FocusSession(
        id: newId(),
        startedAt: today.subtract(const Duration(hours: 6)),
        plannedMinutes: 50,
        focusedMinutes: 50,
        completed: true,
        label: 'Chapter 4 notes',
      ),
      FocusSession(
        id: newId(),
        startedAt: today.subtract(const Duration(days: 1)),
        plannedMinutes: 25,
        focusedMinutes: 12,
        completed: false,
        label: 'Email triage',
      ),
      FocusSession(
        id: newId(),
        startedAt: today.subtract(const Duration(days: 2)),
        plannedMinutes: 25,
        focusedMinutes: 25,
        completed: true,
        label: 'Feature spec',
      ),
    ];
  }

  static List<DiaryEntry> diaryEntries() {
    final today = DateTime.now().dayOnly;

    return <DiaryEntry>[
      DiaryEntry(
        id: newId(),
        date: today,
        title: 'A calm start',
        content:
            'Woke up early and finished a full deep-work block before lunch.\n'
            'Kept the phone in the other room, which made the difference.',
        createdAt: today.add(const Duration(hours: 20)),
        updatedAt: today.add(const Duration(hours: 20)),
      ),
      DiaryEntry(
        id: newId(),
        date: today.subtract(const Duration(days: 1)),
        title: 'Rainy day',
        content:
            'Slow start, but the reading streak held. Walked in the evening and '
            'sketched for an hour.',
        createdAt: today.subtract(const Duration(days: 1, hours: -19)),
        updatedAt: today.subtract(const Duration(days: 1, hours: -19)),
      ),
    ];
  }

  /// Builds a `yyyy-MM-dd` -> value map for the last [days] days.
  static Map<String, int> _lastDays(
    DateTime today,
    int days,
    List<int> values,
  ) {
    final map = <String, int>{};
    for (var i = 0; i < days; i++) {
      final date = today.subtract(Duration(days: days - 1 - i));
      map[date.dayKey] = values[i % values.length];
    }
    return map;
  }
}
