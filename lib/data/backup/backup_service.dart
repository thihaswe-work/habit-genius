import 'dart:convert';
import "dart:typed_data";
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/diary/application/diary_providers.dart';
import '../../features/expenses/application/category_providers.dart';
import '../../features/expenses/application/expense_providers.dart';
import '../../features/focus/application/focus_providers.dart';
import '../../features/habits/application/habit_providers.dart';
import '../../features/mood/application/mood_providers.dart';
import '../models/custom_category.dart';
import '../models/diary_entry.dart';
import '../models/expense_entry.dart';
import '../models/focus_session.dart';
import '../models/habit.dart';
import '../models/mood_entry.dart';
import '../repositories/repository_providers.dart';
import 'backup_model.dart';
final _csv = Csv();

class BackupService {
  BackupService(this.ref);

  final Ref ref;

  AppBackup buildBackup() {
    final habits = ref.read(habitsProvider);
    final moods = ref.read(moodEntriesProvider);
    final expenses = ref.read(expensesProvider);
    final focus = ref.read(focusSessionsProvider);
    final diary = ref.read(diaryEntriesProvider);
    final categories = ref.read(customCategoriesProvider);

    return AppBackup(
      version: 1,
      exportedAt: DateTime.now().toIso8601String(),
      habits: habits.map((e) => e.toJson()).toList(),
      moods: moods.map((e) => e.toJson()).toList(),
      expenses: expenses.map((e) => e.toJson()).toList(),
      focusSessions: focus.map((e) => e.toJson()).toList(),
      diary: diary.map((e) => e.toJson()).toList(),
      customCategories: categories.map((e) => e.toJson()).toList(),
    );
  }

  Future<String> exportJson() async {
    final backup = buildBackup();
    final json = backup.toJsonString();
    final name =
        'habit_genius_backup_${DateTime.now().toIso8601String().replaceAll(':', '-')}.json';
    await FileSaver.instance.saveFile(
      name: name,
      bytes: Uint8List.fromList(utf8.encode(json)),
      mimeType: MimeType.json,
    );
    return name;
  }

  Future<String> exportCsv() async {
    final backup = buildBackup();
    final rows = <List<dynamic>>[
      ['type', 'id', 'date', 'name/title', 'value', 'extra']
    ];
    for (final h in backup.habits) {
      rows.add(['habit', h['id'], h['createdAt'], h['name'], h['target'], jsonEncode(h)]);
    }
    for (final m in backup.moods) {
      rows.add(['mood', m['id'], m['date'], m['moodIndex'], '', jsonEncode(m)]);
    }
    for (final e in backup.expenses) {
      rows.add(['expense', e['id'], e['date'], e['categoryIndex'], e['amount'], jsonEncode(e)]);
    }
    for (final f in backup.focusSessions) {
      rows.add(['focus', f['id'], f['startedAt'], f['plannedMinutes'], f['focusedMinutes'], jsonEncode(f)]);
    }
    for (final d in backup.diary) {
      rows.add(['diary', d['id'], d['date'], d['title'], '', jsonEncode(d)]);
    }
    for (final c in backup.customCategories) {
      rows.add(['category', c['id'], '', c['label'], c['typeIndex'], jsonEncode(c)]);
    }
    final csvStr = _csv.encode(rows);
    final name =
        'habit_genius_backup_${DateTime.now().toIso8601String().replaceAll(':', '-')}.csv';
    await FileSaver.instance.saveFile(
      name: name,
      bytes: Uint8List.fromList(utf8.encode(csvStr)),
      mimeType: MimeType.csv,
    );
    return name;
  }

  Future<String> exportExcel() async {
    final backup = buildBackup();
    final excel = Excel.createExcel();
    _addSheet(excel, 'Habits', [
      ['id', 'name', 'emoji', 'progressType', 'progressKind', 'target', 'unit', 'durationMinutesTarget', 'schedule', 'createdAt', 'isArchived', 'progressByDate'],
      ...backup.habits.map((h) => [
            h['id'],
            h['name'],
            h['emoji'],
            h['progressType'],
            h['progressKind'],
            h['target'],
            h['unit'],
            h['durationMinutesTarget'],
            jsonEncode(h['schedule']),
            h['createdAt'],
            h['isArchived'],
            jsonEncode(h['progressByDate']),
          ]),
    ]);
    _addSheet(excel, 'Moods', [
      ['id', 'date', 'moodIndex', 'note'],
      ...backup.moods.map((m) => [m['id'], m['date'], m['moodIndex'], m['note']]),
    ]);
    _addSheet(excel, 'Expenses', [
      ['id', 'date', 'amount', 'typeIndex', 'categoryIndex', 'note'],
      ...backup.expenses.map((e) => [e['id'], e['date'], e['amount'], e['typeIndex'], e['categoryIndex'], e['note']]),
    ]);
    _addSheet(excel, 'Focus', [
      ['id', 'startedAt', 'plannedMinutes', 'focusedMinutes', 'completed', 'label'],
      ...backup.focusSessions.map((f) => [f['id'], f['startedAt'], f['plannedMinutes'], f['focusedMinutes'], f['completed'], f['label']]),
    ]);
    _addSheet(excel, 'Diary', [
      ['id', 'date', 'title', 'content', 'createdAt', 'updatedAt'],
      ...backup.diary.map((d) => [d['id'], d['date'], d['title'], d['content'], d['createdAt'], d['updatedAt']]),
    ]);
    _addSheet(excel, 'Categories', [
      ['id', 'label', 'emoji', 'typeIndex'],
      ...backup.customCategories.map((c) => [c['id'], c['label'], c['emoji'], c['typeIndex']]),
    ]);
    final bytes = excel.save()!;
    final name =
        'habit_genius_backup_${DateTime.now().toIso8601String().replaceAll(':', '-')}.xlsx';
    await FileSaver.instance.saveFile(
      name: name,
      bytes: Uint8List.fromList(bytes),
      mimeType: MimeType.microsoftExcel,
    );
    return name;
  }

  void _addSheet(Excel excel, String name, List<List<dynamic>> rows) {
    final sheet = excel[name];
    for (var r = 0; r < rows.length; r++) {
      final row = rows[r];
      for (var c = 0; c < row.length; c++) {
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r)).value =
            TextCellValue(row[c]?.toString() ?? '');
      }
    }
  }

  Future<int> importJson() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result.isEmpty) return 0;
    final file = result.first;
    final bytes = await file.readAsBytes();
    final map = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    return _applyBackup(AppBackup.fromJson(map));
  }

  /// Imports a backup CSV exported by [exportCsv]. The full record for each
  /// row is stored in the `extra` column, so all module data is restored.
  Future<int> importCsv() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    if (result.isEmpty) return 0;
    final file = result.first;
    final bytes = await file.readAsBytes();
    final rows = _csv.decode(utf8.decode(bytes));
    if (rows.isEmpty) return 0;

    final habits = <Map<String, dynamic>>[];
    final moods = <Map<String, dynamic>>[];
    final expenses = <Map<String, dynamic>>[];
    final focusSessions = <Map<String, dynamic>>[];
    final diary = <Map<String, dynamic>>[];
    final customCategories = <Map<String, dynamic>>[];

    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.length < 6) continue;
      final type = row[0]?.toString();
      final extra = row[5]?.toString();
      if (type == null || extra == null || extra.isEmpty) continue;
      try {
        final map = (jsonDecode(extra) as Map).cast<String, dynamic>();
        switch (type) {
          case 'habit':
            habits.add(map);
          case 'mood':
            moods.add(map);
          case 'expense':
            expenses.add(map);
          case 'focus':
            focusSessions.add(map);
          case 'diary':
            diary.add(map);
          case 'category':
            customCategories.add(map);
        }
      } catch (_) {}
    }

    return _applyBackup(
      AppBackup(
        version: 1,
        exportedAt: '',
        habits: habits,
        moods: moods,
        expenses: expenses,
        focusSessions: focusSessions,
        diary: diary,
        customCategories: customCategories,
      ),
    );
  }

  Future<int> _applyBackup(AppBackup backup) async {
    int count = 0;

    final habitRepo = ref.read(habitRepositoryProvider);
    for (final h in backup.habits) {
      try {
        await habitRepo.upsert(HabitExt.fromJson(h));
        count++;
      } catch (_) {}
    }
    ref.invalidate(habitsProvider);

    final moodRepo = ref.read(moodRepositoryProvider);
    for (final m in backup.moods) {
      try {
        await moodRepo.save(MoodEntryJson.fromJson(m));
        count++;
      } catch (_) {}
    }
    ref.invalidate(moodEntriesProvider);

    final expenseRepo = ref.read(expenseRepositoryProvider);
    for (final e in backup.expenses) {
      try {
        await expenseRepo.add(ExpenseEntryJson.fromJson(e));
        count++;
      } catch (_) {}
    }
    ref.invalidate(expensesProvider);

    final focusRepo = ref.read(focusRepositoryProvider);
    for (final f in backup.focusSessions) {
      try {
        await focusRepo.save(FocusSessionJson.fromJson(f));
        count++;
      } catch (_) {}
    }
    ref.invalidate(focusSessionsProvider);

    final diaryRepo = ref.read(diaryRepositoryProvider);
    for (final d in backup.diary) {
      try {
        await diaryRepo.save(DiaryEntryJson.fromJson(d));
        count++;
      } catch (_) {}
    }
    ref.invalidate(diaryEntriesProvider);

    final categoryRepo = ref.read(customCategoryRepositoryProvider);
    for (final c in backup.customCategories) {
      try {
        await categoryRepo.save(CustomCategoryJson.fromJson(c));
        count++;
      } catch (_) {}
    }
    ref.invalidate(customCategoriesProvider);

    return count;
  }
}

final backupServiceProvider = Provider<BackupService>((ref) => BackupService(ref));
