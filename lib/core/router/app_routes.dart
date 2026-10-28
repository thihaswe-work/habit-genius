/// Named routes for the whole app.
///
/// Keeping them in one class avoids the stringly-typed navigation bugs that
/// creep in when routes are scattered across feature folders.
abstract final class AppRoutes {
  // Main screens — every mini-app is a top-level route navigated via drawer.
  static const String dashboard = '/';
  static const String habits = '/habits';
  static const String mood = '/mood';
  static const String focus = '/focus';
  static const String expenses = '/expenses';
  static const String diary = '/diary';
  static const String analytics = '/analytics';
  static const String more = '/more';
  static const String settings = '/settings';

  /// The five product modules, in the order they appear on the dashboard.
  static const List<String> modules = <String>[
    habits,
    mood,
    focus,
  ];
}
