import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/section_header.dart';
import 'widgets/focus_history_list.dart';
import 'widgets/pomodoro_timer.dart';

class FocusScreen extends ConsumerWidget {
  const FocusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Focus Timer'),
        leading: const AppMenuButton(),
      ),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.gutter,
                AppSpacing.lg,
                AppSpacing.gutter,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Focus Timer', style: theme.textTheme.headlineSmall),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Pomodoro technique for deep work',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    const Center(child: PomodoroTimer()),
                  ],
                ),
              ),
            ),
            const SliverPadding(
              padding: EdgeInsets.only(
                left: AppSpacing.gutter,
                right: AppSpacing.gutter,
                top: AppSpacing.xxxl,
                bottom: AppSpacing.md,
              ),
              sliver: SliverToBoxAdapter(
                child: SectionHeader(
                  title: 'History',
                  subtitle: 'Your focus sessions',
                ),
              ),
            ),
            const SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
              sliver: SliverToBoxAdapter(child: FocusHistoryList()),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }
}
