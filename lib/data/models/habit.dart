import 'package:flutter/foundation.dart';

import '../../core/utils/date_x.dart';

/// How a habit is completed.
enum HabitProgressType {
  /// Tapped once per day — done or not done.
  checkbox,

  /// Tapped up to [Habit.target] times per day.
  counter,
}

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

  /// Completions recorded for [date].
  int progressOn(DateTime date) => progressByDate[date.dayKey] ?? 0;

  /// Whether the habit is fully completed on [date].
  bool isCompletedOn(DateTime date) => progressOn(date) >= target;

  /// Completion ratio in the `0..1` range for [date].
  double ratioOn(DateTime date) {
    if (target <= 0) return 0;
    return (progressOn(date) / target).clamp(0.0, 1.0);
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
          other.target == target &&
          other.unit == unit &&
          other.createdAt == createdAt &&
          mapEquals(other.progressByDate, progressByDate) &&
          other.isArchived == isArchived;

  @override
  int get hashCode => Object.hash(
        id,
        name,
        emoji,
        progressType,
        target,
        unit,
        createdAt,
        Object.hashAll(
          progressByDate.entries
              .map((e) => Object.hash(e.key, e.value)),
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
        'target': target,
        'unit': unit,
        'createdAt': createdAt.toIso8601String(),
        'progressByDate': progressByDate,
        'isArchived': isArchived,
      };

  static Habit fromJson(Map<String, dynamic> json) => Habit(
        id: json['id'] as String,
        name: json['name'] as String,
        emoji: json['emoji'] as String?,
        progressType: HabitProgressType.values[json['progressType'] as int],
        target: json['target'] as int,
        unit: json['unit'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        progressByDate:
            (json['progressByDate'] as Map).cast<String, int>(),
        isArchived: json['isArchived'] as bool? ?? false,
      );
}

extension HabitExt on Habit {
  static Habit fromJson(Map<String, dynamic> json) => Habit(
        id: json['id'] as String,
        name: json['name'] as String,
        emoji: json['emoji'] as String?,
        progressType: HabitProgressType.values[json['progressType'] as int],
        target: json['target'] as int,
        unit: json['unit'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        progressByDate:
            (json['progressByDate'] as Map).cast<String, int>(),
        isArchived: json['isArchived'] as bool? ?? false,
      );
}
