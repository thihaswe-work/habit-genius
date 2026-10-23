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

    expect(find.textContaining('Good '), findsOneWidget);
    expect(find.text('Habits'), findsWidgets);
    expect(find.text('Mood'), findsWidgets);
    expect(find.text('Focus'), findsWidgets);
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
