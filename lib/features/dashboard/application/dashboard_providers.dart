import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Time-of-day greeting shown at the top of the dashboard.
final greetingProvider = Provider<String>((Ref ref) {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  if (hour < 21) return 'Good evening';
  return 'Good night';
});

/// Human readable date, e.g. `Wednesday, 22 October`.
final todayLabelProvider = Provider<String>((Ref ref) {
  return DateFormat('EEEE, d MMMM').format(DateTime.now());
});

/// Short weekday + day number, e.g. `Wed 22`.
final shortTodayLabelProvider = Provider<String>((Ref ref) {
  return DateFormat('EEE d').format(DateTime.now());
});
