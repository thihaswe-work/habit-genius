import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/date_x.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/section_header.dart';
import '../../../data/models/habit.dart';
import '../application/habit_providers.dart';
import 'widgets/add_habit_sheet.dart';
import 'widgets/habit_card.dart';

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  static final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsProvider);
    final today = DateTime.now();
    final todayHabits = ref.watch(todayHabitsProvider);
    final done = todayHabits.where((h) => h.isCompletedOn(today)).length;
    final total = todayHabits.length;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        key: _scaffoldKey,
        drawer: const AppDrawer(),
        appBar: AppBar(
          title: const Text('Habits'),
          leading: AppMenuButton(scaffoldKey: _scaffoldKey),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Today'),
              Tab(text: 'All Habits'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // ── Tab 1: Today ──
            _TodayTab(
              habits: todayHabits,
              today: today,
              done: done,
              total: total,
            ),
            // ── Tab 2: All Habits ──
            _AllHabitsTab(habits: habits, today: today),
            // ── Tab 3: History ──
            _HistoryTab(habits: habits),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              builder: (_) => const AddHabitSheet(),
            );
          },
          backgroundColor: AppColors.habits,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: const Text('Add habit', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}

/// Shows today's progress banner and only the habits scheduled for today.
class _TodayTab extends StatelessWidget {
  const _TodayTab({
    required this.habits,
    required this.today,
    required this.done,
    required this.total,
  });

  final List<Habit> habits;
  final DateTime today;
  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
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
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.habits, AppColors.habitsAlt],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Today's progress",
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            total == 0
                                ? 'Create your first habit'
                                : '$done of $total completed',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusPill,
                            ),
                            child: LinearProgressIndicator(
                              value: total == 0 ? 0 : done / total,
                              minHeight: 8,
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.25,
                              ),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Container(
                      width: 64,
                      height: 64,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        total == 0 ? '✨' : '$done',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
                title: 'Your habits',
                subtitle: 'Track your routine',
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
            sliver: habits.isEmpty
                ? SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusXl,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Text('🎯', style: TextStyle(fontSize: 36)),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'No habits yet',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Tap the button below to create your first habit',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SliverList.builder(
                    itemCount: habits.length,
                    itemBuilder: (context, index) {
                      final habit = habits[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: HabitCard(habit: habit, date: today),
                      );
                    },
                  ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

/// Shows all habits with their overall stats — not filtered by today.
class _AllHabitsTab extends StatelessWidget {
  const _AllHabitsTab({required this.habits, required this.today});

  final List<Habit> habits;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (habits.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎯', style: TextStyle(fontSize: 48)),
            const SizedBox(height: AppSpacing.md),
            Text('No habits yet', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Tap "Add habit" to get started',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return SafeArea(
      bottom: false,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          AppSpacing.lg,
          AppSpacing.gutter,
          100,
        ),
        itemCount: habits.length,
        itemBuilder: (context, index) {
          final habit = habits[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: HabitCard(habit: habit, date: today),
          );
        },
      ),
    );
  }
}

class _HistoryTab extends StatefulWidget {
  const _HistoryTab({required this.habits});

  final List<Habit> habits;

  @override
  State<_HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<_HistoryTab> {
  late DateTime _selectedDate;

  DateTime get _today => DateTime.now().dayOnly;

  DateTime get _firstHabitDay {
    if (widget.habits.isEmpty) {
      return _today.subtract(const Duration(days: 365));
    }
    return widget.habits
        .map((habit) => habit.createdAt.dayOnly)
        .reduce((a, b) => a.isBefore(b) ? a : b);
  }

  @override
  void initState() {
    super.initState();
    final yesterday = _today.subtract(const Duration(days: 1));
    _selectedDate = yesterday.isBefore(_firstHabitDay) ? _today : yesterday;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: _firstHabitDay,
      lastDate: _today,
      helpText: 'Choose a day to review',
    );
    if (picked != null) setState(() => _selectedDate = picked.dayOnly);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheduled = widget.habits
        .where(
          (habit) =>
              !habit.createdAt.dayOnly.isAfter(_selectedDate) &&
              habit.schedule.shouldDoOn(_selectedDate),
        )
        .toList();
    final completed = scheduled
        .where((habit) => habit.isCompletedOn(_selectedDate))
        .length;
    final isToday = _selectedDate.isSameDay(_today);
    final previousDay = _selectedDate.subtract(const Duration(days: 1));
    final nextDay = _selectedDate.add(const Duration(days: 1));

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: <Widget>[
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.gutter,
              AppSpacing.lg,
              AppSpacing.gutter,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: Row(
                  children: <Widget>[
                    IconButton(
                      tooltip: 'Previous day',
                      onPressed: _selectedDate.isAfter(_firstHabitDay)
                          ? () => setState(() => _selectedDate = previousDay)
                          : null,
                      icon: const Icon(Icons.chevron_left_rounded),
                    ),
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                        onTap: _pickDate,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.sm,
                          ),
                          child: Column(
                            children: <Widget>[
                              Text(
                                isToday
                                    ? 'Today'
                                    : DateFormat('EEEE').format(_selectedDate),
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                DateFormat('MMMM d, y').format(_selectedDate),
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Choose date',
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_month_rounded),
                    ),
                    IconButton(
                      tooltip: 'Next day',
                      onPressed: !isToday && nextDay.isBefore(_today)
                          ? () => setState(() => _selectedDate = nextDay)
                          : null,
                      icon: const Icon(Icons.chevron_right_rounded),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.gutter,
              AppSpacing.md,
              AppSpacing.gutter,
              AppSpacing.lg,
            ),
            sliver: SliverToBoxAdapter(
              child: Text(
                widget.habits.isEmpty
                    ? 'Add habits to start building your history.'
                    : scheduled.isEmpty
                    ? 'No habits were scheduled for this day.'
                    : '$completed of ${scheduled.length} habits completed',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ),
          if (scheduled.isEmpty)
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.gutter,
              ),
              sliver: SliverToBoxAdapter(
                child: SectionHeader(
                  title: 'Nothing scheduled',
                  subtitle: isToday
                      ? 'You can still review today’s progress here.'
                      : 'Pick another date to review your routine.',
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.gutter,
              ),
              sliver: SliverList.builder(
                itemCount: scheduled.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: HabitCard(
                    habit: scheduled[index],
                    date: _selectedDate,
                    readOnly: true,
                  ),
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
