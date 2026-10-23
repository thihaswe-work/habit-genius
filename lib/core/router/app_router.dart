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
import "../../features/shell/presentation/app_shell.dart";
import 'app_routes.dart';

/// The application router.
///
/// A `StatefulShellRoute` provides the bottom navigation bar: every branch
/// keeps an independent navigation stack, while module pages such as the
/// expense tracker live as children of the "More" branch so they still show
/// the navigation bar.
final appRouterProvider = Provider<GoRouter>((Ref ref) {
  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    routes: <RouteBase>[
      StatefulShellRoute.indexedStack(
        builder: (BuildContext context, GoRouterState state,
                StatefulNavigationShell navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.dashboard,
                name: 'dashboard',
                builder: (BuildContext context, GoRouterState state) =>
                    const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.habits,
                name: 'habits',
                builder: (BuildContext context, GoRouterState state) =>
                    const HabitsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.mood,
                name: 'mood',
                builder: (BuildContext context, GoRouterState state) =>
                    const MoodScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.focus,
                name: 'focus',
                builder: (BuildContext context, GoRouterState state) =>
                    const FocusScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.more,
                name: 'more',
                builder: (BuildContext context, GoRouterState state) =>
                    const MoreScreen(),
                routes: const <RouteBase>[],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (BuildContext context, GoRouterState state) =>
            const SettingsScreen(),
      ),
      GoRoute(
        path: '/expenses',
        name: 'expenses',
        builder: (BuildContext context, GoRouterState state) =>
            const ExpensesScreen(),
      ),
      GoRoute(
        path: '/analytics',
        name: 'analytics',
        builder: (BuildContext context, GoRouterState state) =>
            const AnalyticsScreen(),
      ),
    ],
  );
});
