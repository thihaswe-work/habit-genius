/// Named routes for the whole app.
///
/// Keeping them in one class avoids the stringly-typed navigation bugs that
/// creep in when routes are scattered across feature folders.
abstract final class AppRoutes {
  // Bottom-navigation branches (each keeps its own navigation stack).
  static const String dashboard = '/';
  static const String habits = '/habits';
  static const String mood = '/mood';
  static const String focus = '/focus';
  static const String more = '/more';

  // Sub-pages hosted by the "More" branch.
  static const String expenses = '/more/expenses';
  static const String diary = '/more/diary';

  /// The five product modules, in the order they appear on the dashboard.
  static const List<String> modules = <String>[
    habits,
    mood,
    focus,
    expenses,
    diary,
  ];
}
