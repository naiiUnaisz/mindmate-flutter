import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(ThemeMode.light);

Future<void> loadThemePreference() async {
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('theme_dark') ?? false;
  themeModeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
}

Future<void> setThemeMode(bool isDark) async {
  themeModeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('theme_dark', isDark);
}

bool isDarkMode() => themeModeNotifier.value == ThemeMode.dark;
