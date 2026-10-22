import 'dart:convert';

import 'package:hive_ce/hive_ce.dart';

import '../../../core/utils/date_x.dart';
import '../../models/habit.dart';
import '../../repositories/habit_repository.dart';

class HiveHabitRepository implements HabitRepository {
  HiveHabitRepository(this.box);

  final Box<dynamic> box;

  static const String _key = 'habits';

  List<Habit> _cache = const [];

  List<Habit> _load() {
    final raw = box.get(_key);
    if (raw == null) {
      _cache = const [];
      return _cache;
    }
    final list = jsonDecode(raw as String) as List;
    _cache = list
        .map((e) => HabitExt.fromJson(e as Map<String, dynamic>))
        .toList();
    return _cache;
  }

  Future<void> _save() async {
    final json = jsonEncode(_cache.map((e) => e.toJson()).toList());
    await box.put(_key, json);
  }

  @override
  List<Habit> getAll() {
    if (_cache.isEmpty && box.get(_key) != null) return _load();
    if (_cache.isEmpty) return const [];
    return List<Habit>.unmodifiable(_cache);
  }

  @override
  List<Habit> getActive() =>
      getAll().where((h) => !h.isArchived).toList();

  @override
  Future<void> upsert(Habit habit) async {
    if (_cache.isEmpty && box.get(_key) != null) {
      _load();
    }
    final index = _cache.indexWhere((h) => h.id == habit.id);
    if (index == -1) {
      _cache = [..._cache, habit];
    } else {
      final updated = [..._cache];
      updated[index] = habit;
      _cache = updated;
    }
    await _save();
  }

  @override
  Future<void> delete(String id) async {
    if (_cache.isEmpty && box.get(_key) != null) {
      _load();
    }
    _cache = _cache.where((h) => h.id != id).toList();
    await _save();
  }

  @override
  Future<void> setProgress(Habit habit, DateTime date, int value) async {
    final progress = Map<String, int>.from(habit.progressByDate);
    final key = date.dayKey;
    if (value <= 0) {
      progress.remove(key);
    } else {
      progress[key] = value;
    }
    await upsert(habit.copyWith(progressByDate: progress));
  }

  @override
  Future<void> toggle(Habit habit, DateTime date) async {
    final current = habit.progressOn(date);
    await setProgress(habit, date, current > 0 ? 0 : 1);
  }
}
