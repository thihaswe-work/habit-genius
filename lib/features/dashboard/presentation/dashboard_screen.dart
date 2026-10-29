import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/section_header.dart';
import '../../../data/models/habit.dart';
import '../../focus/application/focus_providers.dart';
import '../../habits/application/habit_providers.dart';
import '../../habits/presentation/widgets/reminders_sheet.dart';
import '../../mood/application/mood_providers.dart';
import '../application/dashboard_providers.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/focus_snapshot_card.dart';
import 'widgets/mood_snapshot_card.dart';
import 'widgets/quick_actions_grid.dart';
import 'widgets/today_habits_card.dart';
import 'widgets/today_overview_strip.dart';

/// The home screen: a live summary of the day plus shortcuts to every module.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final greeting = ref.watch(greetingProvider);
    final dateLabel = ref.watch(todayLabelProvider);

    final habits = ref.watch(habitsProvider);
    final completion = ref.watch(habitCompletionProvider);
    final mood = ref.watch(todayMoodProvider);
    final focusMinutes = ref.watch(todayFocusMinutesProvider);

    final streak = habits.isEmpty
        ? 0
        : habits
            .map((Habit h) => h.streak())
            .fold<int>(0, (int best, int value) => value > best ? value : best);

    final stats = <OverviewStat>[
      OverviewStat(
        label: 'Habits done',
        value: '${completion.done}/${completion.total}',
        icon: Icons.check_circle_rounded,
        color: AppColors.habits,
      ),
      OverviewStat(
        label: 'Mood',
        value: mood?.mood.label ?? 'Not set',
        emoji: mood?.mood.emoji ?? '🫥',
        color: AppColors.mood,
      ),
      OverviewStat(
        label: 'Focus',
        value: '${focusMinutes}m',
        icon: Icons.timer_rounded,
        color: AppColors.focus,
      ),
    ];

    return Scaffold(
      drawer: const AppDrawer(),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: <Widget>[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.gutter,
                AppSpacing.md,
                AppSpacing.gutter,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: Builder(
                  builder: (context) => DashboardHeader(
                    greeting: greeting,
                    dateLabel: dateLabel,
                    streak: streak,
                    onMenuTap: () => Scaffold.of(context).openDrawer(),
                    onRemindersTap: () => showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      showDragHandle: true,
                      builder: (_) => const RemindersSheet(),
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.gutter,
                AppSpacing.xl,
                AppSpacing.gutter,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: TodayOverviewStrip(stats: stats),
              ),
            ),
            const SliverPadding(
              padding: EdgeInsets.only(
                left: AppSpacing.gutter,
                right: AppSpacing.gutter,
                top: AppSpacing.xxl,
                bottom: AppSpacing.md,
              ),
              sliver: SliverToBoxAdapter(
                child: SectionHeader(
                  title: 'Your modules',
                  subtitle: 'Everything you track, one tap away',
                ),
              ),
            ),
            const SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
              sliver: SliverToBoxAdapter(child: QuickActionsGrid()),
            ),
            const SliverPadding(
              padding: EdgeInsets.only(
                left: AppSpacing.gutter,
                right: AppSpacing.gutter,
                top: AppSpacing.xxl,
                bottom: AppSpacing.md,
              ),
              sliver: SliverToBoxAdapter(
                child: SectionHeader(title: 'Today'),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
              sliver: SliverList.list(
                children: <Widget>[
                  const TodayHabitsCard(),
                  const SizedBox(height: AppSpacing.md),
                  const MoodSnapshotCard(),
                  const SizedBox(height: AppSpacing.md),
                  const FocusSnapshotCard(),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
