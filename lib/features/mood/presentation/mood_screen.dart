import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_drawer.dart';
import '../application/mood_providers.dart';
import 'widgets/mood_checkin_card.dart';
import 'widgets/mood_history_list.dart';

class MoodScreen extends ConsumerWidget {
  const MoodScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final entries = ref.watch(moodEntriesProvider);
    final avg = ref.watch(moodAverageProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        drawer: const AppDrawer(),
        appBar: AppBar(
          title: const Text('Mood Journal'),
          leading: const AppMenuButton(),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Check-in'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // ── Tab 1: Check-in ──
            _CheckInTab(
              entries: entries,
              avg: avg,
              theme: theme,
            ),
            // ── Tab 2: History ──
            const _HistoryTab(),
          ],
        ),
      ),
    );
  }
}

class _CheckInTab extends StatelessWidget {
  const _CheckInTab({
    required this.entries,
    required this.avg,
    required this.theme,
  });

  final List entries;
  final double? avg;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          AppSpacing.lg,
          AppSpacing.gutter,
          AppSpacing.xxxl,
        ),
        children: [
          Row(
            children: [
              Expanded(
                child: _Stat(
                  label: 'Entries',
                  value: '${entries.length}',
                  icon: Icons.calendar_month_rounded,
                  color: AppColors.mood,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _Stat(
                  label: '7-day avg',
                  value: avg == null ? '—' : avg!.toStringAsFixed(1),
                  icon: Icons.insights_rounded,
                  color: AppColors.habits,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          const MoodCheckinCard(),
        ],
      ),
    );
  }
}

class _HistoryTab extends StatelessWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          AppSpacing.lg,
          AppSpacing.gutter,
          AppSpacing.xxxl,
        ),
        children: const [
          MoodHistoryList(),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: theme.textTheme.titleMedium),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
