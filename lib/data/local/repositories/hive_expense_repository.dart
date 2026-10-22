import 'dart:convert';

import 'package:hive_ce/hive_ce.dart';

import '../../models/expense_entry.dart';
import '../../repositories/expense_repository.dart';

class HiveExpenseRepository implements ExpenseRepository {
  HiveExpenseRepository(this.box);

  final Box<dynamic> box;
  static const String _key = 'expenses';

  List<ExpenseEntry> _cache = const [];

  List<ExpenseEntry> _load() {
    final raw = box.get(_key);
    if (raw == null) {
      _cache = const [];
      return _cache;
    }
    final list = jsonDecode(raw as String) as List;
    _cache = list
        .map((e) => ExpenseEntryJson.fromJson(e as Map<String, dynamic>))
        .toList();
    final sorted = List<ExpenseEntry>.from(_cache)
      ..sort((a, b) => b.date.compareTo(a.date));
    _cache = sorted;
    return _cache;
  }

  Future<void> _save() async {
    final json = jsonEncode(_cache.map((e) => e.toJson()).toList());
    await box.put(_key, json);
  }

  @override
  List<ExpenseEntry> getAll() {
    if (_cache.isEmpty && box.get(_key) != null) return _load();
    final sorted = List<ExpenseEntry>.from(_cache)
      ..sort((a, b) => b.date.compareTo(a.date));
    return List<ExpenseEntry>.unmodifiable(sorted);
  }

  @override
  Future<void> add(ExpenseEntry entry) async {
    if (_cache.isEmpty && box.get(_key) != null) {
      _load();
    }
    _cache = [entry, ..._cache];
    _cache = List<ExpenseEntry>.from(_cache)
      ..sort((a, b) => b.date.compareTo(a.date));
    await _save();
  }

  @override
  Future<void> update(ExpenseEntry entry) async {
    if (_cache.isEmpty && box.get(_key) != null) {
      _load();
    }
    final index = _cache.indexWhere((e) => e.id == entry.id);
    if (index != -1) {
      final updated = [..._cache];
      updated[index] = entry;
      _cache = updated;
      _cache = List<ExpenseEntry>.from(_cache)
        ..sort((a, b) => b.date.compareTo(a.date));
      await _save();
    }
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
