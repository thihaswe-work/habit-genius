import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/id_x.dart';
import '../../../data/models/custom_category.dart';
import '../../../data/models/expense_entry.dart';
import '../../../data/repositories/repository_providers.dart';

/// User-defined income and expense categories.
final customCategoriesProvider =
    NotifierProvider<CustomCategoriesNotifier, List<CustomCategory>>(
  CustomCategoriesNotifier.new,
);

/// Custom categories for a single [TransactionType].
final categoriesForTypeProvider =
    Provider.family<List<CustomCategory>, TransactionType>((ref, type) {
  final categories = ref.watch(customCategoriesProvider);
  return categories.where((c) => c.type == type).toList();
});

class CustomCategoriesNotifier extends Notifier<List<CustomCategory>> {
  @override
  List<CustomCategory> build() =>
      ref.read(customCategoryRepositoryProvider).getAll();

  Future<CustomCategory> create({
    required String label,
    required String emoji,
    required TransactionType type,
  }) async {
    final category = CustomCategory(
      id: newId(),
      label: label.trim(),
      emoji: emoji,
      type: type,
    );
    await ref.read(customCategoryRepositoryProvider).save(category);
    state = ref.read(customCategoryRepositoryProvider).getAll();
    return category;
  }

  Future<void> delete(String id) async {
    await ref.read(customCategoryRepositoryProvider).delete(id);
    state = ref.read(customCategoryRepositoryProvider).getAll();
  }
}
