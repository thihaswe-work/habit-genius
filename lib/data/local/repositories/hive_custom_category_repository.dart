import 'dart:convert';

import 'package:hive_ce/hive_ce.dart';

import '../../models/custom_category.dart';
import '../../repositories/custom_category_repository.dart';

class HiveCustomCategoryRepository implements CustomCategoryRepository {
  HiveCustomCategoryRepository(this.box);

  final Box<dynamic> box;
  static const String _key = 'expense_categories';

  List<CustomCategory> _cache = const [];

  List<CustomCategory> _load() {
    final raw = box.get(_key);
    if (raw == null) {
      _cache = const [];
      return _cache;
    }
    final list = jsonDecode(raw as String) as List;
    _cache = list
        .map((e) => CustomCategoryJson.fromJson(e as Map<String, dynamic>))
        .toList();
    return _cache;
  }

  Future<void> _save() async {
    final json = jsonEncode(_cache.map((e) => e.toJson()).toList());
    await box.put(_key, json);
  }

  @override
  List<CustomCategory> getAll() {
    if (_cache.isEmpty && box.get(_key) != null) return _load();
    return List<CustomCategory>.unmodifiable(_cache);
  }

  @override
  Future<void> save(CustomCategory category) async {
    if (_cache.isEmpty && box.get(_key) != null) {
      _load();
    }
    final index = _cache.indexWhere((c) => c.id == category.id);
    if (index == -1) {
      _cache = [..._cache, category];
    } else {
      final updated = [..._cache];
      updated[index] = category;
      _cache = updated;
    }
    await _save();
  }

  @override
  Future<void> delete(String id) async {
    if (_cache.isEmpty && box.get(_key) != null) {
      _load();
    }
    _cache = _cache.where((c) => c.id != id).toList();
    await _save();
  }
}
