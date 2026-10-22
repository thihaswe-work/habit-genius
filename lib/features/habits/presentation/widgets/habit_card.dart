import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../data/models/habit.dart';
import '../../application/habit_providers.dart';

class HabitCard extends ConsumerWidget {
  const HabitCard({
    super.key,
    required this.habit,
    required this.date,
    this.onEdit,
  });

  final Habit habit;
  final DateTime date;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final progress = habit.progressOn(date);
    final completed = habit.isCompletedOn(date);
    final notifier = ref.read(habitsProvider.notifier);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: completed
                      ? AppColors.habits.withValues(alpha: 0.16)
                      : theme.colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Text(
                  habit.emoji ?? '🎯',
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(habit.name, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      habit.progressType == HabitProgressType.checkbox
                          ? (completed ? 'Completed' : 'Tap to complete')
                          : '$progress / ${habit.target} ${habit.unit ?? 'times'}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (onEdit != null)
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.more_horiz_rounded),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (habit.progressType == HabitProgressType.checkbox)
            GestureDetector(
              onTap: () => notifier.toggle(habit, date),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 52,
                decoration: BoxDecoration(
                  color: completed
                      ? AppColors.habits
                      : theme.colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      completed
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: completed ? Colors.white : theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      completed ? 'Done' : 'Mark as done',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: completed ? Colors.white : theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Row(
              children: [
                _IconBtn(
                  icon: Icons.remove_rounded,
                  onTap: progress > 0
                      ? () => notifier.decrement(habit, date)
                      : null,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                      child: LinearProgressIndicator(
                        value: habit.ratioOn(date),
                        minHeight: 10,
                        backgroundColor: theme.colorScheme.surfaceContainer,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          completed ? AppColors.success : AppColors.habits,
                        ),
                      ),
                    ),
                  ),
                ),
                _IconBtn(
                  icon: Icons.add_rounded,
                  onTap: () => notifier.increment(habit, date),
                  filled: !completed,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({
    required this.icon,
    required this.onTap,
    this.filled = false,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = onTap != null;
    return Material(
      color: filled && enabled
          ? AppColors.habits
          : theme.colorScheme.surfaceContainer,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(
            icon,
            color: filled && enabled
                ? Colors.white
                : enabled
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }
}
