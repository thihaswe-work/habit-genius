import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:habit_genius/app.dart';

void main() {
  testWidgets('dashboard renders, opens drawer, and navigates', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: HabitGeniusApp()));
    await tester.pumpAndSettle();

    expect(find.textContaining('Good '), findsOneWidget);

    // Tap menu button on dashboard
    await tester.tap(find.byTooltip('Menu'));
    await tester.pumpAndSettle();

    expect(find.byType(Drawer), findsOneWidget);
    expect(find.text('HabitGenius'), findsOneWidget);

    // Tap Habits in drawer
    await tester.tap(find.widgetWithText(ListTile, 'Habits'));
    await tester.pumpAndSettle();

    // Drawer should be closed and Habits screen displayed
    expect(find.byType(Drawer), findsNothing);
    expect(find.text('All Habits'), findsOneWidget);

    // Open drawer from Habits screen
    await tester.tap(find.byTooltip('Menu'));
    await tester.pumpAndSettle();

    expect(find.byType(Drawer), findsOneWidget);

    // Navigate back to Dashboard
    await tester.tap(find.widgetWithText(ListTile, 'Dashboard'));
    await tester.pumpAndSettle();

    expect(find.byType(Drawer), findsNothing);
    expect(find.textContaining('Good '), findsOneWidget);
  });
}
