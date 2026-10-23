import 'package:flutter/foundation.dart';

import 'expense_entry.dart';

/// A user-defined income or expense category.
@immutable
class CustomCategory {
  const CustomCategory({
    required this.id,
    required this.label,
    required this.emoji,
    required this.type,
  });

  final String id;
  final String label;
  final String emoji;
  final TransactionType type;

  CustomCategory copyWith({
    String? id,
    String? label,
    String? emoji,
    TransactionType? type,
  }) {
    return CustomCategory(
      id: id ?? this.id,
      label: label ?? this.label,
      emoji: emoji ?? this.emoji,
      type: type ?? this.type,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomCategory &&
          other.id == id &&
          other.label == label &&
          other.emoji == emoji &&
          other.type == type;

  @override
  int get hashCode => Object.hash(id, label, emoji, type);
}

extension CustomCategoryJson on CustomCategory {
  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'emoji': emoji,
        'typeIndex': type.index,
      };

  static CustomCategory fromJson(Map<String, dynamic> json) {
    final typeIndex = (json['typeIndex'] as int?) ?? 1;
    return CustomCategory(
      id: json['id'] as String,
      label: json['label'] as String,
      emoji: (json['emoji'] as String?) ?? '🏷️',
      type: typeIndex >= 0 && typeIndex < TransactionType.values.length
          ? TransactionType.values[typeIndex]
          : TransactionType.expense,
    );
  }
}
