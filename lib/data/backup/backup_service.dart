import 'dart:convert';
import 'dart:typed_data';

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
      ['id', 'date', 'amount', 'typeIndex', 'categoryIndex', 'note', 'customCategory', 'customEmoji'],
      ...backup.expenses.map((e) => [
            e['id'],
            e['date'],
            e['amount'],
            e['typeIndex'],
            e['categoryIndex'],
            e['note'],
            e['customCategory'],
            e['customEmoji'],
          ]),
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

  Future<String> exportSql() async {
    final backup = buildBackup();
    final buffer = StringBuffer()
      ..writeln('-- HabitGenius SQL backup')
      ..writeln('-- Generated: ${backup.exportedAt}')
      ..writeln('-- Version: ${backup.version}')
      ..writeln()
      ..writeln('BEGIN TRANSACTION;')
      ..writeln();

    void createTable(String name, String cols) {
      buffer.writeln('CREATE TABLE IF NOT EXISTS $name ($cols);');
    }

    createTable('habit_genius_habits',
        'id TEXT PRIMARY KEY, name TEXT, emoji TEXT, progress_type INTEGER, progress_kind INTEGER, target INTEGER, unit TEXT, duration_minutes_target INTEGER, schedule TEXT, created_at TEXT, is_archived INTEGER, progress_by_date TEXT');
    createTable('habit_genius_moods',
        'id TEXT PRIMARY KEY, date TEXT, mood_index INTEGER, note TEXT');
    createTable('habit_genius_expenses',
        'id TEXT PRIMARY KEY, date TEXT, amount REAL, type_index INTEGER, category_index INTEGER, note TEXT, custom_category TEXT, custom_emoji TEXT');
    createTable('habit_genius_focus',
        'id TEXT PRIMARY KEY, started_at TEXT, planned_minutes INTEGER, focused_minutes INTEGER, completed INTEGER, label TEXT');
    createTable('habit_genius_diary',
        'id TEXT PRIMARY KEY, date TEXT, title TEXT, content TEXT, created_at TEXT, updated_at TEXT');
    createTable('habit_genius_categories',
        'id TEXT PRIMARY KEY, label TEXT, emoji TEXT, type_index INTEGER');
    buffer.writeln();

    String sqlString(String? s) {
      if (s == null) return 'NULL';
      final escaped = s.replaceAll("'", "''");
      return "'$escaped'";
    }

    for (final h in backup.habits) {
      buffer.writeln(
          "INSERT OR REPLACE INTO habit_genius_habits VALUES (${sqlString(h['id'])}, ${sqlString(h['name'])}, ${sqlString(h['emoji'])}, ${h['progressType'] ?? 0}, ${h['progressKind']}, ${h['target'] ?? 1}, ${sqlString(h['unit'])}, ${h['durationMinutesTarget'] ?? 0}, ${sqlString(jsonEncode(h['schedule']))}, ${sqlString(h['createdAt'])}, ${(h['isArchived'] == true) ? 1 : 0}, ${sqlString(jsonEncode(h['progressByDate']))});");
    }
    for (final m in backup.moods) {
      buffer.writeln(
          "INSERT OR REPLACE INTO habit_genius_moods VALUES (${sqlString(m['id'])}, ${sqlString(m['date'])}, ${m['moodIndex'] ?? 0}, ${sqlString(m['note'])});");
    }
    for (final e in backup.expenses) {
      buffer.writeln(
          "INSERT OR REPLACE INTO habit_genius_expenses VALUES (${sqlString(e['id'])}, ${sqlString(e['date'])}, ${e['amount'] ?? 0}, ${e['typeIndex'] ?? 0}, ${e['categoryIndex'] ?? 0}, ${sqlString(e['note'])}, ${sqlString(e['customCategory'])}, ${sqlString(e['customEmoji'])});");
    }
    for (final f in backup.focusSessions) {
      buffer.writeln(
          "INSERT OR REPLACE INTO habit_genius_focus VALUES (${sqlString(f['id'])}, ${sqlString(f['startedAt'])}, ${f['plannedMinutes'] ?? 0}, ${f['focusedMinutes'] ?? 0}, ${(f['completed'] == true) ? 1 : 0}, ${sqlString(f['label'])});");
    }
    for (final d in backup.diary) {
      buffer.writeln(
          "INSERT OR REPLACE INTO habit_genius_diary VALUES (${sqlString(d['id'])}, ${sqlString(d['date'])}, ${sqlString(d['title'])}, ${sqlString(d['content'])}, ${sqlString(d['createdAt'])}, ${sqlString(d['updatedAt'])});");
    }
    for (final c in backup.customCategories) {
      buffer.writeln(
          "INSERT OR REPLACE INTO habit_genius_categories VALUES (${sqlString(c['id'])}, ${sqlString(c['label'])}, ${sqlString(c['emoji'])}, ${c['typeIndex'] ?? 1});");
    }

    buffer
      ..writeln()
      ..writeln('COMMIT;');
    final name =
        'habit_genius_backup_${DateTime.now().toIso8601String().replaceAll(':', '-')}.sql';
    await FileSaver.instance.saveFile(
      name: name,
      bytes: Uint8List.fromList(utf8.encode(buffer.toString())),
      mimeType: MimeType.other,
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

  Future<int> importExcel() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );
    if (result.isEmpty) return 0;
    final file = result.first;
    final bytes = await file.readAsBytes();
    final excel = Excel.decodeBytes(bytes);

    List<List<Data?>> sheet(String name) {
      final s = excel.tables[name];
      if (s == null) return const [];
      final rows = <List<Data?>>[];
      for (var r = 0; r < s.rows.length; r++) {
        final row = s.rows[r];
        rows.add([for (var c = 0; c < row.length; c++) row[c]]);
      }
      return rows;
    }

    String? cell(List<List<Data?>> rows, int r, int c) {
      if (r >= rows.length) return null;
      final row = rows[r];
      if (c >= row.length) return null;
      return row[c]?.value?.toString();
    }

    final habitsRows = sheet('Habits');
    final moodsRows = sheet('Moods');
    final expensesRows = sheet('Expenses');
    final focusRows = sheet('Focus');
    final diaryRows = sheet('Diary');
    final catRows = sheet('Categories');

    final habits = <Map<String, dynamic>>[];
    for (var i = 1; i < habitsRows.length; i++) {
      try {
        final id = cell(habitsRows, i, 0);
        final name = cell(habitsRows, i, 1);
        if (id == null || name == null) continue;
        habits.add({
          'id': id,
          'name': name,
          'emoji': cell(habitsRows, i, 2),
          'progressType': int.tryParse(cell(habitsRows, i, 3) ?? '0') ?? 0,
          'progressKind': int.tryParse(cell(habitsRows, i, 4) ?? ''),
          'target': int.tryParse(cell(habitsRows, i, 5) ?? '1') ?? 1,
          'unit': cell(habitsRows, i, 6),
          'durationMinutesTarget':
              int.tryParse(cell(habitsRows, i, 7) ?? '0') ?? 0,
          'schedule': cell(habitsRows, i, 8) == null
              ? const {}
              : jsonDecode(cell(habitsRows, i, 8)!),
          'createdAt': cell(habitsRows, i, 9) ?? DateTime.now().toIso8601String(),
          'isArchived': cell(habitsRows, i, 10) == 'true',
          'progressByDate': cell(habitsRows, i, 11) == null
              ? const {}
              : jsonDecode(cell(habitsRows, i, 11)!),
        });
      } catch (_) {}
    }

    final moods = <Map<String, dynamic>>[];
    for (var i = 1; i < moodsRows.length; i++) {
      try {
        final id = cell(moodsRows, i, 0);
        final date = cell(moodsRows, i, 1);
        if (id == null || date == null) continue;
        moods.add({
          'id': id,
          'date': date,
          'moodIndex': int.tryParse(cell(moodsRows, i, 2) ?? '0') ?? 0,
          'note': cell(moodsRows, i, 3),
        });
      } catch (_) {}
    }

    final expenses = <Map<String, dynamic>>[];
    for (var i = 1; i < expensesRows.length; i++) {
      try {
        final id = cell(expensesRows, i, 0);
        final date = cell(expensesRows, i, 1);
        final amount = double.tryParse(cell(expensesRows, i, 2) ?? '0');
        if (id == null || date == null || amount == null) continue;
        expenses.add({
          'id': id,
          'date': date,
          'amount': amount,
          'typeIndex': int.tryParse(cell(expensesRows, i, 3) ?? '1') ?? 1,
          'categoryIndex': int.tryParse(cell(expensesRows, i, 4) ?? '7') ?? 7,
          'note': cell(expensesRows, i, 5),
          'customCategory': cell(expensesRows, i, 6),
          'customEmoji': cell(expensesRows, i, 7),
        });
      } catch (_) {}
    }

    final focus = <Map<String, dynamic>>[];
    for (var i = 1; i < focusRows.length; i++) {
      try {
        final id = cell(focusRows, i, 0);
        final startedAt = cell(focusRows, i, 1);
        if (id == null || startedAt == null) continue;
        focus.add({
          'id': id,
          'startedAt': startedAt,
          'plannedMinutes': int.tryParse(cell(focusRows, i, 2) ?? '0') ?? 0,
          'focusedMinutes': int.tryParse(cell(focusRows, i, 3) ?? '0') ?? 0,
          'completed': cell(focusRows, i, 4) == 'true',
          'label': cell(focusRows, i, 5),
        });
      } catch (_) {}
    }

    final diary = <Map<String, dynamic>>[];
    for (var i = 1; i < diaryRows.length; i++) {
      try {
        final id = cell(diaryRows, i, 0);
        final date = cell(diaryRows, i, 1);
        if (id == null || date == null) continue;
        diary.add({
          'id': id,
          'date': date,
          'title': cell(diaryRows, i, 2),
          'content': cell(diaryRows, i, 3) ?? '',
          'createdAt': cell(diaryRows, i, 4) ?? DateTime.now().toIso8601String(),
          'updatedAt': cell(diaryRows, i, 5) ?? DateTime.now().toIso8601String(),
        });
      } catch (_) {}
    }

    final categories = <Map<String, dynamic>>[];
    for (var i = 1; i < catRows.length; i++) {
      try {
        final id = cell(catRows, i, 0);
        final label = cell(catRows, i, 1);
        if (id == null || label == null) continue;
        categories.add({
          'id': id,
          'label': label,
          'emoji': cell(catRows, i, 2),
          'typeIndex': int.tryParse(cell(catRows, i, 3) ?? '1') ?? 1,
        });
      } catch (_) {}
    }

    return _applyBackup(
      AppBackup(
        version: 1,
        exportedAt: '',
        habits: habits,
        moods: moods,
        expenses: expenses,
        focusSessions: focus,
        diary: diary,
        customCategories: categories,
      ),
    );
  }

  Future<int> importSql() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['sql'],
    );
    if (result.isEmpty) return 0;
    final file = result.first;
    final bytes = await file.readAsBytes();
    final sql = utf8.decode(bytes);

    final habits = <Map<String, dynamic>>[];
    final moods = <Map<String, dynamic>>[];
    final expenses = <Map<String, dynamic>>[];
    final focus = <Map<String, dynamic>>[];
    final diary = <Map<String, dynamic>>[];
    final categories = <Map<String, dynamic>>[];

    String? unquote(String s) {
      final t = s.trim();
      if (t == 'NULL') return null;
      if (t.startsWith("'") && t.endsWith("'")) {
        return t.substring(1, t.length - 1).replaceAll("''", "'");
      }
      return t;
    }

    List<String> values(String line) {
      final m = RegExp(r"VALUES\s*\((.+)\);", caseSensitive: false).firstMatch(line);
      if (m == null) return [];
      final inner = m.group(1)!;
      final parts = <String>[];
      var current = StringBuffer();
      bool inQuote = false;
      for (var i = 0; i < inner.length; i++) {
        final c = inner[i];
        if (c == "'" && (i == 0 || inner[i - 1] != '\\')) {
          inQuote = !inQuote;
          current.write(c);
        } else if (c == ',' && !inQuote) {
          parts.add(current.toString());
          current = StringBuffer();
        } else {
          current.write(c);
        }
      }
      parts.add(current.toString());
      return parts;
    }

    for (final raw in sql.split('\n')) {
      final line = raw.trim();
      if (line.isEmpty || line.startsWith('--')) continue;
      final v = values(line);
      if (v.isEmpty) continue;
      try {
        if (line.toLowerCase().contains('into habit_genius_habits')) {
          final schedule = unquote(v[8]);
          final progress = unquote(v[11]);
          habits.add({
            'id': unquote(v[0]),
            'name': unquote(v[1]),
            'emoji': unquote(v[2]),
            'progressType': int.tryParse(v[3].trim()) ?? 0,
            'progressKind': int.tryParse(v[4].trim()),
            'target': int.tryParse(v[5].trim()) ?? 1,
            'unit': unquote(v[6]),
            'durationMinutesTarget': int.tryParse(v[7].trim()) ?? 0,
            'schedule': schedule == null ? const {} : jsonDecode(schedule),
            'createdAt': unquote(v[9]),
            'isArchived': v[10].trim() == '1',
            'progressByDate': progress == null ? const {} : jsonDecode(progress),
          });
        } else if (line.toLowerCase().contains('into habit_genius_moods')) {
          moods.add({
            'id': unquote(v[0]),
            'date': unquote(v[1]),
            'moodIndex': int.tryParse(v[2].trim()) ?? 0,
            'note': unquote(v[3]),
          });
        } else if (line.toLowerCase().contains('into habit_genius_expenses')) {
          expenses.add({
            'id': unquote(v[0]),
            'date': unquote(v[1]),
            'amount': double.tryParse(v[2].trim()) ?? 0,
            'typeIndex': int.tryParse(v[3].trim()) ?? 0,
            'categoryIndex': int.tryParse(v[4].trim()) ?? 0,
            'note': unquote(v[5]),
            'customCategory': unquote(v[6]),
            'customEmoji': unquote(v[7]),
          });
        } else if (line.toLowerCase().contains('into habit_genius_focus')) {
          focus.add({
            'id': unquote(v[0]),
            'startedAt': unquote(v[1]),
            'plannedMinutes': int.tryParse(v[2].trim()) ?? 0,
            'focusedMinutes': int.tryParse(v[3].trim()) ?? 0,
            'completed': v[4].trim() == '1',
            'label': unquote(v[5]),
          });
        } else if (line.toLowerCase().contains('into habit_genius_diary')) {
          diary.add({
            'id': unquote(v[0]),
            'date': unquote(v[1]),
            'title': unquote(v[2]),
            'content': unquote(v[3]) ?? '',
            'createdAt': unquote(v[4]),
            'updatedAt': unquote(v[5]),
          });
        } else if (line.toLowerCase().contains('into habit_genius_categories')) {
          categories.add({
            'id': unquote(v[0]),
            'label': unquote(v[1]),
            'emoji': unquote(v[2]),
            'typeIndex': int.tryParse(v[3].trim()) ?? 1,
          });
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
        focusSessions: focus,
        diary: diary,
        customCategories: categories,
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
