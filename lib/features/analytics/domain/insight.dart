import 'package:flutter/foundation.dart';

enum InsightTone { positive, warning, neutral }

@immutable
class Insight {
  const Insight({
    required this.title,
    required this.message,
    this.tone = InsightTone.neutral,
  });

  final String title;
  final String message;
  final InsightTone tone;
}

@immutable
class HabitBreakdown {
  const HabitBreakdown({required this.title, required this.steps});

  final String title;
  final List<String> steps;
}
