import 'package:flutter/foundation.dart';

import '../../core/utils/date_x.dart';

/// How a habit is completed.
enum HabitProgressType {
  /// Tapped once per day — done or not done.
  checkbox,

  /// Tapped up to [Habit.target] times per day.
  counter,
}

/// Day of week used by [HabitSchedule].
enum Weekday {
  monday(1),
  tuesday(2),
  wednesday(3),
  thursday(4),
  friday(5),
  saturday(6),
  sunday(7);

  const Weekday(this.value);
  final int value;

  static Weekday fromDateTime(DateTime dt) {
    return Weekday.values.firstWhere((w) => w.value == dt.weekday);
  }
}

/// Optional time-of-day grouping for a habit.
enum TimeOfDayFilter { any, morning, afternoon, evening }

/// When a habit should be performed.
@immutable
class HabitSchedule {
  const HabitSchedule({
    this.timeOfDay = TimeOfDayFilter.any,
    this.weekdays = const <Weekday>{},
    this.reminderMinutes,
    this.intervalDays = 1,
  });

  final TimeOfDayFilter timeOfDay;

  /// Empty means every day.
  final Set<Weekday> weekdays;

  /// Minutes since midnight for a daily reminder, or null for none.
  final int? reminderMinutes;

  /// 1 = daily, 2 = every other day, etc.
  final int intervalDays;

  bool shouldDoOn(DateTime date) {
    if (intervalDays > 1) {
      return date.difference(DateTime(date.year)).inDays % intervalDays == 0;
    }
    if (weekdays.isEmpty) return true;
    return weekdays.contains(Weekday.fromDateTime(date));
  }

  HabitSchedule copyWith({
    TimeOfDayFilter? timeOfDay,
    Set<Weekday>? weekdays,
    int? reminderMinutes,
    int? intervalDays,
  }) {
    return HabitSchedule(
      timeOfDay: timeOfDay ?? this.timeOfDay,
      weekdays: weekdays ?? this.weekdays,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      intervalDays: intervalDays ?? this.intervalDays,
    );
  }

  Map<String, dynamic> toJson() => {
        'timeOfDay': timeOfDay.index,
        'weekdays': weekdays.map((w) => w.value).toList(),
        'reminderMinutes': reminderMinutes,
        'intervalDays': intervalDays,
      };

  static HabitSchedule fromJson(Map<String, dynamic> json) {
    final days = (json['weekdays'] as List?)
            ?.map((e) => Weekday.values.firstWhere((w) => w.value == e))
            .toSet() ??
        <Weekday>{};
    return HabitSchedule(
      timeOfDay: TimeOfDayFilter.values[(json['timeOfDay'] as int?) ?? 0],
      weekdays: days,
      reminderMinutes: json['reminderMinutes'] as int?,
      intervalDays: json['intervalDays'] as int? ?? 1,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitSchedule &&
          other.timeOfDay == timeOfDay &&
          setEquals(other.weekdays, weekdays) &&
          other.reminderMinutes == reminderMinutes &&
          other.intervalDays == intervalDays;

  @override
  int get hashCode => Object.hash(
        timeOfDay,
        Object.hashAll(weekdays.map((w) => w.value)),
        reminderMinutes,
        intervalDays,
      );
}

/// Extended progress kinds. [HabitProgressType] is kept for back-compat.
enum HabitProgressKind { checkbox, counter, duration }

/// A tracked routine.
@immutable
class Habit {
  const Habit({
    required this.id,
    required this.name,
    required this.progressType,
    required this.createdAt,
    this.emoji,
    this.target = 1,
    this.unit,
    this.progressByDate = const <String, int>{},
    this.isArchived = false,
    this.progressKind,
    this.durationMinutesTarget = 0,
    this.schedule = const HabitSchedule(),
  });

  final String id;
  final String name;
  final String? emoji;
  final HabitProgressType progressType;

  /// Number of completions required for a counter habit. Always `1` for
  /// checkbox habits.
  final int target;

  /// Optional unit shown next to a counter, e.g. `pages` or `glasses`.
  final String? unit;

  final DateTime createdAt;

  /// Progress keyed by `yyyy-MM-dd`. The value is the completion count for
  /// that day (1 for checkbox habits).
  final Map<String, int> progressByDate;

  final bool isArchived;

  /// Extended kind, falling back to the legacy [progressType].
  final HabitProgressKind? progressKind;

  /// Target duration in minutes for [HabitProgressKind.duration] habits.
  final int durationMinutesTarget;

  final HabitSchedule schedule;

  HabitProgressKind get kind =>
      progressKind ??
      (progressType == HabitProgressType.counter
          ? HabitProgressKind.counter
          : HabitProgressKind.checkbox);

  /// Number of completions required on any given day for this habit.
  int get effectiveTarget {
    if (kind == HabitProgressKind.checkbox) return 1;
    if (kind == HabitProgressKind.duration) {
      return durationMinutesTarget > 0
          ? durationMinutesTarget
          : (target > 0 ? target : 1);
    }
    return target > 0 ? target : 1;
  }

  /// Completions recorded for [date].
  int progressOn(DateTime date) => progressByDate[date.dayKey] ?? 0;

  /// Whether the habit is fully completed on [date].
  bool isCompletedOn(DateTime date) =>
      progressOn(date) >= effectiveTarget;

  /// Completion ratio in the `0..1` range for [date].
  double ratioOn(DateTime date) {
    final t = effectiveTarget;
    if (t <= 0) return 0;
    return (progressOn(date) / t).clamp(0.0, 1.0);
  }

  /// Consecutive days completed up to and including [date].
  int streak({DateTime? from}) {
    final end = from ?? DateTime.now();
    var count = 0;
    var cursor = end.dayOnly;

    // A day that has not been ticked yet does not break the streak.
    if (!isCompletedOn(cursor)) {
      cursor = cursor.subtract(const Duration(days: 1));
    }

    while (isCompletedOn(cursor)) {
      count++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return count;
  }

  Habit copyWith({
    String? id,
    String? name,
    String? emoji,
    HabitProgressType? progressType,
    int? target,
    String? unit,
    DateTime? createdAt,
    Map<String, int>? progressByDate,
    bool? isArchived,
    HabitProgressKind? progressKind,
    int? durationMinutesTarget,
    HabitSchedule? schedule,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      progressType: progressType ?? this.progressType,
      target: target ?? this.target,
      unit: unit ?? this.unit,
      createdAt: createdAt ?? this.createdAt,
      progressByDate: progressByDate ?? this.progressByDate,
      isArchived: isArchived ?? this.isArchived,
      progressKind: progressKind ?? this.progressKind,
      durationMinutesTarget:
          durationMinutesTarget ?? this.durationMinutesTarget,
      schedule: schedule ?? this.schedule,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Habit &&
          other.id == id &&
          other.name == name &&
          other.emoji == emoji &&
          other.progressType == progressType &&
          other.progressKind == progressKind &&
          other.target == target &&
          other.unit == unit &&
          other.durationMinutesTarget == durationMinutesTarget &&
          other.schedule == schedule &&
          other.createdAt == createdAt &&
          mapEquals(other.progressByDate, progressByDate) &&
          other.isArchived == isArchived;

  @override
  int get hashCode => Object.hash(
        id,
        name,
        emoji,
        progressType,
        progressKind,
        target,
        unit,
        durationMinutesTarget,
        schedule,
        createdAt,
        Object.hashAll(
          progressByDate.entries.map((e) => Object.hash(e.key, e.value)),
        ),
        isArchived,
      );
}

extension HabitJson on Habit {
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'progressType': progressType.index,
        'progressKind': progressKind?.index,
        'target': target,
        'unit': unit,
        'durationMinutesTarget': durationMinutesTarget,
        'schedule': schedule.toJson(),
        'createdAt': createdAt.toIso8601String(),
        'progressByDate': progressByDate,
        'isArchived': isArchived,
      };

  static Habit fromJson(Map<String, dynamic> json) {
    final ptIndex = (json['progressType'] as int?) ?? 0;
    final progressType = ptIndex >= 0 && ptIndex < HabitProgressType.values.length
        ? HabitProgressType.values[ptIndex]
        : HabitProgressType.checkbox;
    final pkIndex = json['progressKind'] as int?;
    final progressKind = pkIndex != null &&
            pkIndex >= 0 &&
            pkIndex < HabitProgressKind.values.length
        ? HabitProgressKind.values[pkIndex]
        : null;
    final rawSchedule = json['schedule'];
    final schedule = rawSchedule is Map
        ? HabitSchedule.fromJson(Map<String, dynamic>.from(rawSchedule))
        : const HabitSchedule();
    return Habit(
      id: json['id'] as String,
      name: json['name'] as String,
      emoji: json['emoji'] as String?,
      progressType: progressType,
      target: (json['target'] as int?) ?? 1,
      unit: json['unit'] as String?,
      createdAt:
          DateTime.tryParse((json['createdAt'] as String?) ?? '') ??
              DateTime.now(),
      progressByDate:
          (json['progressByDate'] as Map?)?.cast<String, int>() ??
              const <String, int>{},
      isArchived: (json['isArchived'] as bool?) ?? false,
      progressKind: progressKind,
      durationMinutesTarget: (json['durationMinutesTarget'] as int?) ?? 0,
      schedule: schedule,
    );
  }
}

extension HabitExt on Habit {
  static Habit fromJson(Map<String, dynamic> json) => HabitJson.fromJson(json);

  Habit toggle(DateTime date) {
    final key = date.dayKey;
    final map = Map<String, int>.from(progressByDate);
    map[key] = (map[key] ?? 0) >= effectiveTarget ? 0 : effectiveTarget;
    return copyWith(progressByDate: map);
  }

  Habit increment(DateTime date, [int amount = 1]) {
    final key = date.dayKey;
    final map = Map<String, int>.from(progressByDate);
    map[key] = (map[key] ?? 0) + amount;
    return copyWith(progressByDate: map);
  }

  Habit decrement(DateTime date, [int amount = 1]) {
    final key = date.dayKey;
    final map = Map<String, int>.from(progressByDate);
    final next = (map[key] ?? 0) - amount;
    map[key] = next < 0 ? 0 : next;
    return copyWith(progressByDate: map);
  }

  Habit setProgress(DateTime date, int value) {
    final key = date.dayKey;
    final map = Map<String, int>.from(progressByDate);
    map[key] = value < 0 ? 0 : value;
    return copyWith(progressByDate: map);
  }
}
