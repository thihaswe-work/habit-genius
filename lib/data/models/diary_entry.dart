import 'package:flutter/foundation.dart';

/// A free-form journal entry, one per day.
@immutable
class DiaryEntry {
  const DiaryEntry({
    required this.id,
    required this.date,
    required this.content,
    this.title = '',
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final DateTime date;
  final String title;
  final String content;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// First line or short preview of the entry.
  String get preview {
    final trimmed = content.trim();
    if (trimmed.length <= 120) return trimmed;
    return '${trimmed.substring(0, 120).trimRight()}…';
  }

  DiaryEntry copyWith({
    String? id,
    DateTime? date,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DiaryEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiaryEntry &&
          other.id == id &&
          other.date == date &&
          other.title == title &&
          other.content == content &&
          other.createdAt == createdAt &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(id, date, title, content, createdAt, updatedAt);
}

extension DiaryEntryJson on DiaryEntry {
  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'title': title,
        'content': content,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  static DiaryEntry fromJson(Map<String, dynamic> json) => DiaryEntry(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        title: json['title'] as String? ?? '',
        content: json['content'] as String? ?? '',
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : null,
      );
}
