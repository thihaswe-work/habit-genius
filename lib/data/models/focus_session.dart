import 'package:flutter/foundation.dart';

/// A completed (or abandoned) focus block.
@immutable
class FocusSession {
  const FocusSession({
    required this.id,
    required this.startedAt,
    required this.plannedMinutes,
    required this.focusedMinutes,
    required this.completed,
    this.label,
  });

  final String id;
  final DateTime startedAt;

  /// Length of the block when it was started (e.g. `25`).
  final int plannedMinutes;

  /// Minutes actually focused (may be less than [plannedMinutes]).
  final int focusedMinutes;

  /// Whether the timer ran to zero.
  final bool completed;

  /// Optional description of what the user worked on.
  final String? label;

  FocusSession copyWith({
    String? id,
    DateTime? startedAt,
    int? plannedMinutes,
    int? focusedMinutes,
    bool? completed,
    String? label,
  }) {
    return FocusSession(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      plannedMinutes: plannedMinutes ?? this.plannedMinutes,
      focusedMinutes: focusedMinutes ?? this.focusedMinutes,
      completed: completed ?? this.completed,
      label: label ?? this.label,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FocusSession &&
          other.id == id &&
          other.startedAt == startedAt &&
          other.plannedMinutes == plannedMinutes &&
          other.focusedMinutes == focusedMinutes &&
          other.completed == completed &&
          other.label == label;

  @override
  int get hashCode =>
      Object.hash(id, startedAt, plannedMinutes, focusedMinutes, completed, label);
}

extension FocusSessionJson on FocusSession {
  Map<String, dynamic> toJson() => {
        'id': id,
        'startedAt': startedAt.toIso8601String(),
        'plannedMinutes': plannedMinutes,
        'focusedMinutes': focusedMinutes,
        'completed': completed,
        'label': label,
      };

  static FocusSession fromJson(Map<String, dynamic> json) => FocusSession(
        id: json['id'] as String,
        startedAt: DateTime.parse(json['startedAt'] as String),
        plannedMinutes: json['plannedMinutes'] as int,
        focusedMinutes: json['focusedMinutes'] as int,
        completed: json['completed'] as bool,
        label: json['label'] as String?,
      );
}
