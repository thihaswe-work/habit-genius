import 'package:flutter/foundation.dart';

/// The five moods a user can log, ordered from worst to best.
enum Mood {
  awful(label: 'Awful', emoji: '😢', score: 1),
  bad(label: 'Bad', emoji: '😕', score: 2),
  okay(label: 'Okay', emoji: '😐', score: 3),
  good(label: 'Good', emoji: '🙂', score: 4),
  great(label: 'Great', emoji: '🤩', score: 5);

  const Mood({
    required this.label,
    required this.emoji,
    required this.score,
  });

  final String label;
  final String emoji;

  /// Numeric weight used for averages and charts.
  final int score;
}

/// One mood log for a day.
@immutable
class MoodEntry {
  const MoodEntry({
    required this.id,
    required this.date,
    required this.mood,
    this.note,
  });

  final String id;
  final DateTime date;
  final Mood mood;
  final String? note;

  MoodEntry copyWith({
    String? id,
    DateTime? date,
    Mood? mood,
    String? note,
  }) {
    return MoodEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      mood: mood ?? this.mood,
      note: note ?? this.note,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoodEntry &&
          other.id == id &&
          other.date == date &&
          other.mood == mood &&
          other.note == note;

  @override
  int get hashCode => Object.hash(id, date, mood, note);
}

extension MoodEntryJson on MoodEntry {
  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'moodIndex': mood.index,
        'note': note,
      };

  static MoodEntry fromJson(Map<String, dynamic> json) => MoodEntry(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        mood: Mood.values[json['moodIndex'] as int],
        note: json['note'] as String?,
      );
}
