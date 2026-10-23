import '../../../core/utils/date_x.dart';
import '../../../data/models/habit.dart';
import '../../habits/application/streak_engine.dart';
import '../domain/insight.dart';

/// Generates pattern-based insights and habit breakdown suggestions.
class InsightsEngine {
  InsightsEngine._();

  /// Aggregate consistency across all habits for the last [days] days.
  static double overallCompletionRate(List<Habit> habits, {int days = 30}) {
    final active = habits.where((h) => !h.isArchived).toList();
    if (active.isEmpty) return 0;
    final total = active.fold<double>(
      0,
      (sum, h) => sum + StreakEngine.completionRate(h, days: days),
    );
    return total / active.length;
  }

  /// Average Genius score across all active habits.
  static double averageGeniusScore(List<Habit> habits) {
    final active = habits.where((h) => !h.isArchived).toList();
    if (active.isEmpty) return 0;
    final total = active.fold<double>(
      0,
      (sum, h) => sum + StreakEngine.geniusScore(h),
    );
    return total / active.length;
  }

  /// Completion rate per weekday over the last [weeks] weeks.
  static Map<Weekday, double> weekdayRates(List<Habit> habits,
      {int weeks = 8}) {
    final active = habits.where((h) => !h.isArchived).toList();
    final done = <Weekday, int>{for (final w in Weekday.values) w: 0};
    final scheduled = <Weekday, int>{for (final w in Weekday.values) w: 0};
    final end = DateTime.now().dayOnly;

    for (var i = 0; i < weeks * 7; i++) {
      final date = end.subtract(Duration(days: i));
      final day = Weekday.fromDateTime(date);
      for (final habit in active) {
        if (!habit.schedule.shouldDoOn(date)) continue;
        scheduled[day] = scheduled[day]! + 1;
        if (habit.isCompletedOn(date)) done[day] = done[day]! + 1;
      }
    }
    return {
      for (final w in Weekday.values)
        w: scheduled[w] == 0 ? 0 : done[w]! / scheduled[w]!,
    };
  }

  static List<Insight> generate(List<Habit> habits) {
    final active = habits.where((h) => !h.isArchived).toList();
    if (active.isEmpty) {
      return const [
        Insight(
          title: 'Start small',
          message:
              'Add your first habit and we will start spotting patterns for you.',
        ),
      ];
    }

    final insights = <Insight>[];
    final score = averageGeniusScore(active);
    final rate = overallCompletionRate(active);

    insights.add(
      Insight(
        title: 'Genius Score ${score.round()}',
        message: rate >= 0.8
            ? 'Excellent consistency over the last 30 days. Keep it up!'
            : rate >= 0.5
                ? 'Solid consistency. A small push could take you to the next level.'
                : 'Consistency is the opportunity: aim to complete one more habit per day this week.',
        tone: rate >= 0.8
            ? InsightTone.positive
            : rate >= 0.5
                ? InsightTone.neutral
                : InsightTone.warning,
      ),
    );

    final rates = weekdayRates(active);
    final best = rates.entries.reduce((a, b) => a.value >= b.value ? a : b);
    final worst = rates.entries.reduce((a, b) => a.value <= b.value ? a : b);
    if (best.value > 0) {
      insights.add(
        Insight(
          title: '${_weekdayName(best.key)} is your strongest day',
          message:
              'You complete ${(best.value * 100).round()}% of scheduled habits on ${_weekdayName(best.key)}s.',
          tone: InsightTone.positive,
        ),
      );
    }
    if (worst.value < best.value) {
      insights.add(
        Insight(
          title: '${_weekdayName(worst.key)} needs attention',
          message:
              'Completion drops to ${(worst.value * 100).round()}% on ${_weekdayName(worst.key)}s. Consider a lighter target or a reminder.',
          tone: InsightTone.warning,
        ),
      );
    }

    final weakest = active.reduce((a, b) =>
        StreakEngine.completionRate(a) <= StreakEngine.completionRate(b)
            ? a
            : b);
    final weakestRate = StreakEngine.completionRate(weakest);
    if (weakestRate < 0.6) {
      insights.add(
        Insight(
          title: 'Break down "${weakest.name}"',
          message:
              'Only ${(weakestRate * 100).round()}% completed in 30 days. Try the 2-minute starter version first.',
          tone: InsightTone.warning,
        ),
      );
    }

    return insights;
  }

  /// Suggests a progressive breakdown for a habit.
  static HabitBreakdown breakdownFor(Habit habit) {
    final lower = habit.name.toLowerCase();
    if (lower.contains('run') || lower.contains('workout')) {
      return const HabitBreakdown(
        title: 'Start with movement',
        steps: [
          '5-minute warm-up walk',
          '2 minutes of the target exercise',
          'Add 1 minute each day you complete it',
          'Full session on days you feel strong',
        ],
      );
    }
    if (lower.contains('read') || lower.contains('book')) {
      return const HabitBreakdown(
        title: 'Make reading tiny',
        steps: [
          'Open the book and read one page',
          'Read for 2 minutes at a fixed time',
          'Ramp up to 5 pages when the streak hits 3',
        ],
      );
    }
    if (lower.contains('meditat') || lower.contains('mind')) {
      return const HabitBreakdown(
        title: 'Meditation ladder',
        steps: [
          'Sit down and take 3 slow breaths',
          '1 minute guided breathing',
          '5 minutes when 1 minute feels easy',
        ],
      );
    }
    if (habit.kind == HabitProgressKind.duration) {
      final target = habit.effectiveTarget;
      final quarter = (target / 4).ceil().clamp(1, target);
      return HabitBreakdown(
        title: 'Progressive duration',
        steps: [
          'Do $quarter minute${quarter == 1 ? '' : 's'} today',
          'Increase by $quarter minutes after 3 successful days',
          'Reach the full $target minutes gradually',
        ],
      );
    }
    if (habit.kind == HabitProgressKind.counter) {
      final target = habit.target;
      final half = (target / 2).ceil().clamp(1, target);
      return HabitBreakdown(
        title: 'Lower the bar first',
        steps: [
          'Start with $half ${habit.unit ?? 'reps'} today',
          'Repeat for 2 days, then add the remaining ${target - half}',
          'Only grow once the current step is easy',
        ],
      );
    }
    return HabitBreakdown(
      title: 'Two-minute version',
      steps: [
        'Do a 2-minute version of "${habit.name}"',
        'Attach it to something you already do daily',
        'Expand the habit after 3 consecutive completions',
      ],
    );
  }

  static String _weekdayName(Weekday day) =>
      day.name[0].toUpperCase() + day.name.substring(1);
}
