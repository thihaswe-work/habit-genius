import 'package:hive_ce/hive_ce.dart';

import 'adapters/habit_adapters.dart';

void registerHiveAdapters() {
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(HabitProgressTypeAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(HabitAdapter());
  }
}
