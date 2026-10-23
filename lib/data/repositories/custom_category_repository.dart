import '../models/custom_category.dart';

/// Persistence contract for user-defined transaction categories.
abstract interface class CustomCategoryRepository {
  List<CustomCategory> getAll();

  Future<void> save(CustomCategory category);

  Future<void> delete(String id);
}
