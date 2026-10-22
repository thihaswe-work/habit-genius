import 'dart:convert';

class AppBackup {
  AppBackup({
    required this.version,
    required this.exportedAt,
    required this.habits,
    required this.moods,
    required this.expenses,
    required this.focusSessions,
    required this.diary,
  });

  final int version;
  final String exportedAt;
  final List<Map<String, dynamic>> habits;
  final List<Map<String, dynamic>> moods;
  final List<Map<String, dynamic>> expenses;
  final List<Map<String, dynamic>> focusSessions;
  final List<Map<String, dynamic>> diary;

  Map<String, dynamic> toJson() => {
        'version': version,
        'exportedAt': exportedAt,
        'habits': habits,
        'moods': moods,
        'expenses': expenses,
        'focusSessions': focusSessions,
        'diary': diary,
      };

  String toJsonString() => const JsonEncoder.withIndent('  ').convert(toJson());

  static AppBackup fromJson(Map<String, dynamic> json) {
    return AppBackup(
      version: json['version'] as int? ?? 1,
      exportedAt: json['exportedAt'] as String? ?? '',
      habits: (json['habits'] as List?)?.cast<Map<String, dynamic>>() ?? [],
      moods: (json['moods'] as List?)?.cast<Map<String, dynamic>>() ?? [],
      expenses: (json['expenses'] as List?)?.cast<Map<String, dynamic>>() ?? [],
      focusSessions:
          (json['focusSessions'] as List?)?.cast<Map<String, dynamic>>() ?? [],
      diary: (json['diary'] as List?)?.cast<Map<String, dynamic>>() ?? [],
    );
  }
}
