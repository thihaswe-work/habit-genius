import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:habit_genius/app.dart';

void main() {
  testWidgets('dashboard renders the module shortcuts', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: HabitGeniusApp()));
    await tester.pumpAndSettle();

    // Greeting from the dashboard header.
    expect(find.textContaining('Good '), findsOneWidget);

    // The five modules plus the "all tools" entry point.
    expect(find.text('Habits'), findsWidgets);
    expect(find.text('Mood'), findsWidgets);
    expect(find.text('Focus'), findsWidgets);
    expect(find.text('Expenses'), findsWidgets);
    expect(find.text('Diary'), findsWidgets);

    // The bottom navigation bar.
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
