import 'package:flutter_test/flutter_test.dart';
import 'package:habit_genius/data/models/habit.dart';
import 'package:habit_genius/features/analytics/application/insights_engine.dart';

String key(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

void main() {
  test('empty habits produce a starter insight', () {
    final insights = InsightsEngine.generate(const []);
    expect(insights, hasLength(1));
    expect(insights.first.title, 'Start small');
  });

  test('computes perfect overall rate', () {
    final today = DateTime.now();
    final habit = Habit(
      id: '1',
      name: 'Read',
      progressType: HabitProgressType.checkbox,
      createdAt: DateTime(2026),
      progressByDate: {
        for (var i = 0; i < 30; i++)
          key(DateTime(today.year, today.month, today.day)
              .subtract(Duration(days: i))): 1,
      },
    );
    expect(
      InsightsEngine.overallCompletionRate([habit]),
      closeTo(1, 0.01),
    );
    expect(InsightsEngine.averageGeniusScore([habit]), greaterThan(80));
  });

  test('breakdown adapts to habit kind', () {
    final counter = Habit(
      id: '1',
      name: 'Pushups',
      progressType: HabitProgressType.counter,
      progressKind: HabitProgressKind.counter,
      target: 20,
      createdAt: DateTime(2026),
    );
    final breakdown = InsightsEngine.breakdownFor(counter);
    expect(breakdown.steps, isNotEmpty);
    expect(breakdown.steps.first, contains('10'));
  });
}
