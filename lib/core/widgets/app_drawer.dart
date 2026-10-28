import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// The main application menu shown in the navigation drawer.
///
/// This is the primary navigation mechanism — all mini-apps are reached
/// through drawer items.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentPath = GoRouterState.of(context).uri.path;

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              margin: const EdgeInsets.all(AppSpacing.md),
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.habits, AppColors.habitsAlt],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🧠', style: TextStyle(fontSize: 32)),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'HabitGenius',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Track. Improve. Repeat.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            _SectionLabel('Daily'),
            _DrawerItem(
              icon: Icons.home_outlined,
              selectedIcon: Icons.home_rounded,
              label: 'Dashboard',
              route: AppRoutes.dashboard,
              currentPath: currentPath,
            ),
            _DrawerItem(
              icon: Icons.check_circle_outline_rounded,
              selectedIcon: Icons.check_circle_rounded,
              label: 'Habits',
              route: AppRoutes.habits,
              currentPath: currentPath,
            ),
            _DrawerItem(
              icon: Icons.sentiment_satisfied_outlined,
              selectedIcon: Icons.sentiment_satisfied_rounded,
              label: 'Mood Journal',
              route: AppRoutes.mood,
              currentPath: currentPath,
            ),
            _DrawerItem(
              icon: Icons.timer_outlined,
              selectedIcon: Icons.timer_rounded,
              label: 'Focus Timer',
              route: AppRoutes.focus,
              currentPath: currentPath,
            ),
            const Divider(indent: AppSpacing.lg, endIndent: AppSpacing.lg),
            _SectionLabel('Money & Notes'),
            _DrawerItem(
              icon: Icons.account_balance_wallet_outlined,
              selectedIcon: Icons.account_balance_wallet_rounded,
              label: 'Expenses & Income',
              route: AppRoutes.expenses,
              currentPath: currentPath,
            ),
            _DrawerItem(
              icon: Icons.book_outlined,
              selectedIcon: Icons.book_rounded,
              label: 'Diary',
              route: AppRoutes.diary,
              currentPath: currentPath,
            ),
            const Divider(indent: AppSpacing.lg, endIndent: AppSpacing.lg),
            _SectionLabel('Insights'),
            _DrawerItem(
              icon: Icons.insights_outlined,
              selectedIcon: Icons.insights_rounded,
              label: 'Analytics & Heatmap',
              route: AppRoutes.analytics,
              currentPath: currentPath,
            ),
            const Divider(indent: AppSpacing.lg, endIndent: AppSpacing.lg),
            _SectionLabel('App'),
            _DrawerItem(
              icon: Icons.grid_view_outlined,
              selectedIcon: Icons.grid_view_rounded,
              label: 'All tools',
              route: AppRoutes.more,
              currentPath: currentPath,
            ),
            _DrawerItem(
              icon: Icons.settings_outlined,
              selectedIcon: Icons.settings_rounded,
              label: 'Settings & Backup',
              route: AppRoutes.settings,
              currentPath: currentPath,
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: Text(
        label.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.route,
    required this.currentPath,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String route;
  final String currentPath;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = currentPath == route;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: ListTile(
        selected: selected,
        selectedTileColor: theme.colorScheme.primary.withValues(alpha: 0.10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        leading: Icon(selected ? selectedIcon : icon),
        title: Text(label),
        onTap: () {
          Navigator.of(context).pop();
          context.go(route);
        },
      ),
    );
  }
}

/// Opens the [AppDrawer] from an AppBar leading slot.
class AppMenuButton extends StatelessWidget {
  const AppMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => IconButton(
        tooltip: 'Menu',
        icon: const Icon(Icons.menu_rounded),
        onPressed: () => Scaffold.of(context).openDrawer(),
      ),
    );
  }
}
