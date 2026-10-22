import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' show Rect;

import 'package:share_plus/share_plus.dart';

import '../models/diary_entry.dart';
import '../models/expense_entry.dart';
import '../models/focus_session.dart';
import '../models/habit.dart';
import '../models/mood_entry.dart';
import '../repositories/diary_repository.dart';
import '../repositories/expense_repository.dart';
import '../repositories/focus_repository.dart';
import '../repositories/habit_repository.dart';
import '../repositories/mood_repository.dart';
import 'backup_model.dart';

/// What was restored from a backup file.
class BackupImportSummary {
  const BackupImportSummary({
    required this.habits,
    required this.moods,
    required this.expenses,
    required this.focusSessions,
    required this.diary,
  });

  final int habits;
  final int moods;
  final int expenses;
  final int focusSessions;
  final int diary;

  int get total => habits + moods + expenses + focusSessions + diary;
}

/// Reads every module into a single portable file and restores it again.
///
/// The backup is plain JSON so it can be shared through any messaging, email
/// or cloud-storage app and imported on another phone.
class BackupService {
  BackupService({
    required this.habits,
    required this.moods,
    required this.expenses,
    required this.focusSessions,
    required this.diary,
  });

  static const int currentVersion = 1;

  final HabitRepository habits;
  final MoodRepository moods;
  final ExpenseRepository expenses;
  final FocusRepository focusSessions;
  final DiaryRepository diary;

  AppBackup createBackup() {
    return AppBackup(
      version: currentVersion,
      exportedAt: DateTime.now().toIso8601String(),
      habits: habits.getAll().map((Habit item) => item.toJson()).toList(),
      moods: moods.getAll().map((MoodEntry item) => item.toJson()).toList(),
      expenses: expenses
          .getAll()
          .map((ExpenseEntry item) => item.toJson())
          .toList(),
      focusSessions: focusSessions
          .getAll()
          .map((FocusSession item) => item.toJson())
          .toList(),
      diary: diary.getAll().map((DiaryEntry item) => item.toJson()).toList(),
    );
  }

  String exportJson() => createBackup().toJsonString();

  /// Opens the platform share sheet with a `.json` backup attached.
  ///
  /// The user can send the file to the other phone through any installed
  /// messaging or storage app.
  Future<ShareResult> shareBackup({Rect? sharePositionOrigin}) {
    final bytes = Uint8List.fromList(utf8.encode(exportJson()));
    final now = DateTime.now();
    final date =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    return SharePlus.instance.share(
      ShareParams(
        files: <XFile>[XFile.fromData(bytes, mimeType: 'application/json')],
        fileNameOverrides: <String>['habit_genius_backup_$date.json'],
        subject: 'Habit Genius backup',
        sharePositionOrigin: sharePositionOrigin,
      ),
    );
  }

  /// Parses [source] and writes it into the repositories.
  ///
  /// When [replace] is `true` the existing data is erased first; otherwise
  /// records with matching ids are overwritten and new ones are added.
  /// Everything is parsed before anything is written so a malformed file
  /// cannot clear existing data.
  Future<BackupImportSummary> importJson(
    String source, {
    bool replace = false,
  }) async {
    final dynamic decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException {
      throw const FormatException('This file is not a valid backup.');
    }

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('This file is not a valid backup.');
    }

    final backup = AppBackup.fromJson(decoded);
    if (backup.version > currentVersion) {
      throw const FormatException(
        'This backup was created by a newer version of the app.',
      );
    }

    final importedHabits = backup.habits.map(HabitExt.fromJson).toList();
    final importedMoods = backup.moods.map(MoodEntryJson.fromJson).toList();
    final importedExpenses = backup.expenses
        .map(ExpenseEntryJson.fromJson)
        .toList();
    final importedFocus = backup.focusSessions
        .map(FocusSessionJson.fromJson)
        .toList();
    final importedDiary = backup.diary.map(DiaryEntryJson.fromJson).toList();

    if (replace) {
      for (final item in habits.getAll()) {
        await habits.delete(item.id);
      }
      for (final item in moods.getAll()) {
        await moods.delete(item.id);
      }
      for (final item in expenses.getAll()) {
        await expenses.delete(item.id);
      }
      for (final item in focusSessions.getAll()) {
        await focusSessions.delete(item.id);
      }
      for (final item in diary.getAll()) {
        await diary.delete(item.id);
      }
    }

    for (final item in importedHabits) {
      await habits.upsert(item);
    }
    for (final item in importedMoods) {
      await moods.save(item);
    }
    for (final item in importedFocus) {
      await focusSessions.save(item);
    }
    for (final item in importedDiary) {
      await diary.save(item);
    }

    final expenseIds = {for (final item in expenses.getAll()) item.id};
    for (final item in importedExpenses) {
      if (expenseIds.contains(item.id)) {
        await expenses.update(item);
      } else {
        await expenses.add(item);
        expenseIds.add(item.id);
      }
    }

    return BackupImportSummary(
      habits: importedHabits.length,
      moods: importedMoods.length,
      expenses: importedExpenses.length,
      focusSessions: importedFocus.length,
      diary: importedDiary.length,
    );
  }
}
