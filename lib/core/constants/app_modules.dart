import 'package:flutter/material.dart';

import '../router/app_routes.dart';
import '../theme/app_colors.dart';

/// Describes a product module (icon, label, accent gradient and route).
///
/// The dashboard grid, the "More" hub and the navigation bar all read from
/// this catalogue, so a module is added to the app in exactly one place.
@immutable
class AppModule {
  const AppModule({
    required this.id,
    required this.title,
    required this.caption,
    required this.icon,
    required this.colors,
    required this.route,
  });

  final String id;
  final String title;
  final String caption;
  final IconData icon;
  final List<Color> colors;
  final String route;

  LinearGradient get gradient => LinearGradient(
        colors: colors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
}

/// The catalogue of the five core modules plus the "all tools" entry point.
abstract final class AppModules {
  static const AppModule habits = AppModule(
    id: 'habits',
    title: 'Habits',
    caption: 'Daily routines',
    icon: Icons.check_circle_rounded,
    colors: [AppColors.habits, AppColors.habitsAlt],
    route: AppRoutes.habits,
  );

  static const AppModule mood = AppModule(
    id: 'mood',
    title: 'Mood',
    caption: 'How you feel',
    icon: Icons.sentiment_satisfied_rounded,
    colors: [AppColors.mood, AppColors.moodAlt],
    route: AppRoutes.mood,
  );

  static const AppModule focus = AppModule(
    id: 'focus',
    title: 'Focus',
    caption: 'Pomodoro timer',
    icon: Icons.timer_rounded,
    colors: [AppColors.focus, AppColors.focusAlt],
    route: AppRoutes.focus,
  );

  static const AppModule expenses = AppModule(
    id: 'expenses',
    title: 'Expenses',
    caption: 'Money in & out',
    icon: Icons.account_balance_wallet_rounded,
    colors: [AppColors.expenses, AppColors.expensesAlt],
    route: AppRoutes.expenses,
  );

  static const AppModule diary = AppModule(
    id: 'diary',
    title: 'Diary',
    caption: 'Journal your day',
    icon: Icons.auto_stories_rounded,
    colors: [AppColors.diary, AppColors.diaryAlt],
    route: AppRoutes.diary,
  );

  /// The five core modules.
  static const List<AppModule> all = <AppModule>[
    habits,
    mood,
    focus,
    expenses,
    diary,
  ];

  /// Entry that opens the "all tools" hub.
  static const AppModule more = AppModule(
    id: 'more',
    title: 'All tools',
    caption: 'Everything else',
    icon: Icons.grid_view_rounded,
    colors: [Color(0xFF4C4A6A), Color(0xFF8B87AD)],
    route: AppRoutes.more,
  );
}
