import 'dart:math';

final Random _random = Random();

/// Generates a short, collision-resistant local identifier.
///
/// Used as the primary key for every locally stored record.
String newId() {
  final stamp = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
  final salt = _random.nextInt(1 << 24).toRadixString(36);
  return '$stamp-$salt';
}
