import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/hive_service.dart';

class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final box = HiveService.instance.box(HiveBoxes.settings);
    final value = box.get('theme_mode') as String?;
    if (value == 'light') return ThemeMode.light;
    if (value == 'dark') return ThemeMode.dark;
    return ThemeMode.system;
  }

  void setThemeMode(ThemeMode mode) {
    final box = HiveService.instance.box(HiveBoxes.settings);
    box.put('theme_mode', mode.name);
    state = mode;
  }

  void toggle() {
    if (state == ThemeMode.light) {
      setThemeMode(ThemeMode.dark);
    } else if (state == ThemeMode.dark) {
      setThemeMode(ThemeMode.system);
    } else {
      setThemeMode(ThemeMode.light);
    }
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(() {
  return ThemeNotifier();
});
