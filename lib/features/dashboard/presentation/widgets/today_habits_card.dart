import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../data/models/habit.dart';
import '../../../habits/application/habit_providers.dart';

/// Shows today's habits with inline completion controls.
class TodayHabitsCard extends ConsumerWidget {
  const TodayHabitsCard({super.key, this.maxHabits = 4});

  /// How many habits fit comfortably on the dashboard.
  final int maxHabits;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final habits = ref.watch(todayHabitsProvider);
    final today = DateTime.now();
    final visible = habits.take(maxHabits).toList();
    final done = habits.where((Habit h) => h.isCompletedOn(today)).length;

    if (habits.isEmpty) {
      return AppCard(
        child: EmptyState(
          icon: Icons.check_circle_outline_rounded,
          title: 'No habits yet',
          message: 'Create your first habit to start building a streak.',
          actionLabel: 'Add habit',
          onAction: () => context.go(AppRoutes.habits),
        ),
      );
    }

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text("Today's habits", style: theme.textTheme.titleMedium),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.10),
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusPill),
                ),
                child: Text(
                  '$done/${habits.length}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              TextButton(
                onPressed: () => context.go(AppRoutes.habits),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                ),
                child: const Text('See all'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          for (final habit in visible) ...<Widget>[
            _HabitRow(habit: habit, date: today),
            if (habit != visible.last)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Divider(height: 1),
              ),
          ],
          if (habits.length > visible.length) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            GestureDetector(
              onTap: () => context.go(AppRoutes.habits),
              child: Text(
                '+ ${habits.length - visible.length} more habits',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HabitRow extends ConsumerWidget {
  const _HabitRow({required this.habit, required this.date});

  final Habit habit;
  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final progress = habit.progressOn(date);
    final completed = habit.isCompletedOn(date);
    final notifier = ref.read(habitsProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: <Widget>[
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: completed
                  ? AppColors.habits.withValues(alpha: 0.12)
                  : theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Text(
              habit.emoji ?? '•',
              style: const TextStyle(fontSize: 18),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  habit.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    decoration:
                        completed ? TextDecoration.lineThrough : null,
                    color: completed
                        ? theme.colorScheme.onSurfaceVariant
                        : theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _subtitle(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          if (habit.kind == HabitProgressKind.checkbox)
            _CheckButton(
              checked: completed,
              onTap: () => notifier.toggle(habit, date),
            )
          else
            _CounterControl(
              value: progress,
              target: habit.effectiveTarget,
              onDecrement: () => habit.kind == HabitProgressKind.duration
                  ? notifier.addMinutes(habit, date, -5)
                  : notifier.decrement(habit, date),
              onIncrement: () => habit.kind == HabitProgressKind.duration
                  ? notifier.addMinutes(habit, date, 5)
                  : notifier.increment(habit, date),
            ),
        ],
      ),
    );
  }

  String _subtitle() {
    switch (habit.kind) {
      case HabitProgressKind.checkbox:
        return habit.schedule.weekdays.isEmpty
            ? 'Daily'
            : habit.schedule.timeOfDay.name;
      case HabitProgressKind.counter:
        final unit = habit.unit ?? 'times';
        return '${habit.progressOn(date)} of ${habit.target} $unit';
      case HabitProgressKind.duration:
        return '${habit.progressOn(date)} of ${habit.effectiveTarget} min';
    }
  }
}

class _CheckButton extends StatelessWidget {
  const _CheckButton({required this.checked, required this.onTap});

  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: checked ? AppColors.habits : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: checked ? AppColors.habits : Colors.grey.shade400,
            width: 2,
          ),
        ),
        child: checked
            ? const Icon(Icons.check_rounded, size: 18, color: Colors.white)
            : null,
      ),
    );
  }
}

class _CounterControl extends StatelessWidget {
  const _CounterControl({
    required this.value,
    required this.target,
    required this.onDecrement,
    required this.onIncrement,
  });

  final int value;
  final int target;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reached = value >= target;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _RoundIconButton(
          icon: Icons.remove_rounded,
          onTap: value > 0 ? onDecrement : null,
        ),
        SizedBox(
          width: 34,
          child: Text(
            '$value/$target',
            textAlign: TextAlign.center,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: reached ? AppColors.habits : theme.colorScheme.onSurface,
            ),
          ),
        ),
        _RoundIconButton(
          icon: Icons.add_rounded,
          onTap: onIncrement,
          emphasized: !reached,
        ),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.onTap,
    this.emphasized = false,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = onTap != null;

    return Material(
      color: emphasized
          ? AppColors.habits.withValues(alpha: 0.12)
          : theme.colorScheme.surfaceContainer,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 30,
          height: 30,
          child: Icon(
            icon,
            size: 16,
            color: enabled
                ? (emphasized ? AppColors.habits : theme.colorScheme.onSurface)
                : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }
}
