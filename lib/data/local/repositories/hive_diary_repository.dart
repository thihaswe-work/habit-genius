import 'dart:convert';

import 'package:hive_ce/hive_ce.dart';

import '../../../core/utils/date_x.dart';
import '../../models/diary_entry.dart';
import '../../repositories/diary_repository.dart';

class HiveDiaryRepository implements DiaryRepository {
  HiveDiaryRepository(this.box);

  final Box<dynamic> box;
  static const String _key = 'diary';

  List<DiaryEntry> _cache = const [];

  List<DiaryEntry> _load() {
    final raw = box.get(_key);
    if (raw == null) {
      _cache = const [];
      return _cache;
    }
    final list = jsonDecode(raw as String) as List;
    _cache = list
        .map((e) => DiaryEntryJson.fromJson(e as Map<String, dynamic>))
        .toList();
    final sorted = List<DiaryEntry>.from(_cache)
      ..sort((a, b) => b.date.compareTo(a.date));
    _cache = sorted;
    return _cache;
  }

  Future<void> _save() async {
    final json = jsonEncode(_cache.map((e) => e.toJson()).toList());
    await box.put(_key, json);
  }

  @override
  List<DiaryEntry> getAll() {
    if (_cache.isEmpty && box.get(_key) != null) return _load();
    final sorted = List<DiaryEntry>.from(_cache)
      ..sort((a, b) => b.date.compareTo(a.date));
    return List<DiaryEntry>.unmodifiable(sorted);
  }

  @override
  DiaryEntry? entryFor(DateTime date) {
    final all = getAll();
    for (final entry in all) {
      if (entry.date.isSameDay(date)) return entry;
    }
    return null;
  }

  @override
  Future<void> save(DiaryEntry entry) async {
    if (_cache.isEmpty && box.get(_key) != null) {
      _load();
    }
    final index = _cache.indexWhere((e) => e.id == entry.id);
    if (index == -1) {
      _cache = [entry, ..._cache];
    } else {
      final updated = [..._cache];
      updated[index] = entry;
      _cache = updated;
    }
    _cache = List<DiaryEntry>.from(_cache)
      ..sort((a, b) => b.date.compareTo(a.date));
    await _save();
  }

  @override
  Future<void> delete(String id) async {
    if (_cache.isEmpty && box.get(_key) != null) {
      _load();
    }
    _cache = _cache.where((e) => e.id != id).toList();
    await _save();
  }
}
