import 'dart:convert';

import 'package:hive_ce/hive_ce.dart';

import '../../../core/utils/date_x.dart';
import '../../models/focus_session.dart';
import '../../repositories/focus_repository.dart';

class HiveFocusRepository implements FocusRepository {
  HiveFocusRepository(this.box);

  final Box<dynamic> box;
  static const String _key = 'focus_sessions';

  List<FocusSession> _cache = const [];

  List<FocusSession> _load() {
    final raw = box.get(_key);
    if (raw == null) {
      _cache = const [];
      return _cache;
    }
    final list = jsonDecode(raw as String) as List;
    _cache = list
        .map((e) => FocusSessionJson.fromJson(e as Map<String, dynamic>))
        .toList();
    final sorted = List<FocusSession>.from(_cache)
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    _cache = sorted;
    return _cache;
  }

  Future<void> _save() async {
    final json = jsonEncode(_cache.map((e) => e.toJson()).toList());
    await box.put(_key, json);
  }

  @override
  List<FocusSession> getAll() {
    if (_cache.isEmpty && box.get(_key) != null) return _load();
    final sorted = List<FocusSession>.from(_cache)
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return List<FocusSession>.unmodifiable(sorted);
  }

  @override
  Future<void> save(FocusSession session) async {
    if (_cache.isEmpty && box.get(_key) != null) {
      _load();
    }
    final index = _cache.indexWhere((s) => s.id == session.id);
    if (index == -1) {
      _cache = [session, ..._cache];
    } else {
      final updated = [..._cache];
      updated[index] = session;
      _cache = updated;
    }
    _cache = List<FocusSession>.from(_cache)
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    await _save();
  }

  @override
  Future<void> delete(String id) async {
    if (_cache.isEmpty && box.get(_key) != null) {
      _load();
    }
    _cache = _cache.where((s) => s.id != id).toList();
    await _save();
  }

  @override
  int focusedMinutesOn(DateTime date) {
    final all = getAll();
    return all
        .where((s) => s.startedAt.isSameDay(date))
        .fold<int>(0, (sum, s) => sum + s.focusedMinutes);
  }
}
