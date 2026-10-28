import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/focus/presentation/focus_screen.dart';
import '../../features/habits/presentation/habits_screen.dart';
import '../../features/mood/presentation/mood_screen.dart';
import '../../features/more/presentation/more_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/analytics/presentation/analytics_screen.dart';
import '../../features/expenses/presentation/expenses_screen.dart';
import '../../features/diary/presentation/diary_screen.dart';
import 'app_routes.dart';

/// The application router.
///
/// All mini-apps are flat top-level routes, navigated via the drawer.
/// In-app navigation within each mini-app uses tabs.
final appRouterProvider = Provider<GoRouter>((Ref ref) {
  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.dashboard,
        name: 'dashboard',
        builder: (BuildContext context, GoRouterState state) =>
            const DashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.habits,
        name: 'habits',
        builder: (BuildContext context, GoRouterState state) =>
            const HabitsScreen(),
      ),
      GoRoute(
        path: AppRoutes.mood,
        name: 'mood',
        builder: (BuildContext context, GoRouterState state) =>
            const MoodScreen(),
      ),
      GoRoute(
        path: AppRoutes.focus,
        name: 'focus',
        builder: (BuildContext context, GoRouterState state) =>
            const FocusScreen(),
      ),
      GoRoute(
        path: AppRoutes.more,
        name: 'more',
        builder: (BuildContext context, GoRouterState state) =>
            const MoreScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (BuildContext context, GoRouterState state) =>
            const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.expenses,
        name: 'expenses',
        builder: (BuildContext context, GoRouterState state) =>
            const ExpensesScreen(),
      ),
      GoRoute(
        path: AppRoutes.analytics,
        name: 'analytics',
        builder: (BuildContext context, GoRouterState state) =>
            const AnalyticsScreen(),
      ),
      GoRoute(
        path: AppRoutes.diary,
        name: 'diary',
        builder: (BuildContext context, GoRouterState state) =>
            const DiaryScreen(),
      ),
    ],
  );
});
