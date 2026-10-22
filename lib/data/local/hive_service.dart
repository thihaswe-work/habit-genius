import 'package:hive_ce_flutter/hive_flutter.dart';

/// Names of the Hive boxes backing each module.
///
/// One box per module keeps writes small and makes a future
/// "export / clear module" feature trivial.
abstract final class HiveBoxes {
  static const String habits = 'habits';
  static const String moods = 'moods';
  static const String expenses = 'expenses';
  static const String focusSessions = 'focus_sessions';
  static const String diary = 'diary';

  static const List<String> all = <String>[
    habits,
    moods,
    expenses,
    focusSessions,
    diary,
  ];
}

/// Owns the Hive lifecycle for the app.
///
/// Initialised once during startup; repositories then read from and write to
/// the exposed boxes. Reads from a Hive box are synchronous, which is why the
/// repository interfaces expose sync getters.
class HiveService {
  HiveService._(this._boxes);

  final Map<String, Box<dynamic>> _boxes;

  static HiveService? _instance;

  /// Whether [init] has completed successfully.
  static bool get isReady => _instance != null;

  /// The initialised service.
  ///
  /// Throws if the app was started without calling [init].
  static HiveService get instance {
    final service = _instance;
    if (service == null) {
      throw StateError('HiveService.init() must be awaited before use.');
    }
    return service;
  }

  /// Opens Hive and every box the app needs.
  static Future<void> init() async {
    await Hive.initFlutter();
    final boxes = <String, Box<dynamic>>{};
    for (final name in HiveBoxes.all) {
      boxes[name] = await Hive.openBox<dynamic>(name);
    }
    _instance = HiveService._(boxes);
  }

  /// The box registered under [name].
  Box<dynamic> box(String name) {
    final box = _boxes[name];
    if (box == null) {
      throw ArgumentError('Unknown Hive box: $name');
    }
    return box;
  }
}
