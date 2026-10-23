import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/section_header.dart';
import '../../../data/models/habit.dart';
import '../../habits/application/habit_providers.dart';
import '../../habits/application/streak_engine.dart';
import '../application/insights_engine.dart';
import '../domain/insight.dart';
import 'widgets/consistency_heatmap.dart';
import 'widgets/weekly_trend_bars.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final habits = ref.watch(habitsProvider);
    final active = habits.where((h) => !h.isArchived).toList();
    final score = InsightsEngine.averageGeniusScore(active);
    final rate = InsightsEngine.overallCompletionRate(active);
    final insights = InsightsEngine.generate(active);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Analytics'),
        leading: const AppMenuButton(),
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.gutter),
          children: [
            Text('Trends & Insights', style: theme.textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Track your consistency over time',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            _GeniusScoreCard(score: score, completionRate: rate),
            const SizedBox(height: AppSpacing.xl),
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: ConsistencyHeatmap(habits: active),
            ),
            const SizedBox(height: AppSpacing.xl),
            const SectionHeader(title: 'Last 7 days'),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: WeeklyTrendBars(habits: active),
            ),
            const SizedBox(height: AppSpacing.xl),
            const SectionHeader(title: 'Habit metrics'),
            const SizedBox(height: AppSpacing.md),
            if (active.isEmpty)
              const EmptyState(
                icon: Icons.insights_rounded,
                title: 'No habits yet',
                message: 'Create a habit to unlock analytics.',
              )
            else
              for (final habit in active) ...[
                _HabitMetricTile(habit: habit),
                const SizedBox(height: AppSpacing.sm),
              ],
            const SizedBox(height: AppSpacing.xl),
            const SectionHeader(title: 'Insights'),
            const SizedBox(height: AppSpacing.md),
            for (final insight in insights) ...[
              _InsightTile(insight: insight),
              const SizedBox(height: AppSpacing.sm),
            ],
          ],
        ),
      ),
    );
  }
}

class _GeniusScoreCard extends StatelessWidget {
  const _GeniusScoreCard({required this.score, required this.completionRate});

  final double score;
  final double completionRate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          SizedBox(
            width: 84,
            height: 84,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 84,
                  height: 84,
                  child: CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: 8,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  ),
                ),
                Text(
                  score.round().toString(),
                  style: theme.textTheme.titleLarge,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Habit Genius Score',
                    style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${(completionRate * 100).round()}% 30-day consistency',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HabitMetricTile extends StatelessWidget {
  const _HabitMetricTile({required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metrics = StreakEngine.metrics(habit);
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: () => showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Break down "${habit.name}"'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final step in InsightsEngine.breakdownFor(habit).steps)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Text('• $step'),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Got it'),
            ),
          ],
        ),
      ),
      child: Row(
        children: [
          Text(habit.emoji ?? '🎯', style: const TextStyle(fontSize: 22)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(habit.name, style: theme.textTheme.bodyLarge),
                const SizedBox(height: 2),
                Text(
                  'Streak ${metrics.currentStreak}  ·  Best ${metrics.longestStreak}  ·  ${(metrics.completionRate30Days * 100).round()}% / 30d',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            metrics.geniusScore.round().toString(),
            style: theme.textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

class _InsightTile extends StatelessWidget {
  const _InsightTile({required this.insight});

  final Insight insight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = switch (insight.tone) {
      InsightTone.positive => Colors.green,
      InsightTone.warning => Colors.orange,
      InsightTone.neutral => theme.colorScheme.primary,
    };
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome_rounded, size: 18, color: color),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(insight.title, style: theme.textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(
                  insight.message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
