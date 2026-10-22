import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../focus/application/focus_providers.dart';

/// Today's focus time with a shortcut to the Pomodoro timer.
class FocusSnapshotCard extends ConsumerWidget {
  const FocusSnapshotCard({super.key, this.focusMinutes = 25});

  /// Length of one pomodoro, in minutes.
  final int focusMinutes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final minutes = ref.watch(todayFocusMinutesProvider);
    final sessions = ref.watch(todayCompletedSessionsProvider);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: <Widget>[
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: <Color>[AppColors.focus, AppColors.focusAlt],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: const Icon(
              Icons.timer_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Focus timer', style: theme.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  minutes == 0
                      ? 'No focus time yet today'
                      : '$minutes min focused · $sessions pomodoro${sessions == 1 ? '' : 's'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          FilledButton.icon(
            onPressed: () => context.go(AppRoutes.focus),
            icon: const Icon(Icons.play_arrow_rounded, size: 20),
            label: const Text('Start'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.focus,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              minimumSize: const Size(0, 40),
            ),
          ),
        ],
      ),
    );
  }
}
