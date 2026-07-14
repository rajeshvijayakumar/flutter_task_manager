import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeProvider = NotifierProvider<ThemeController, ThemeState>(
  ThemeController.new,
);

class ThemeState {
  final ThemeMode themeMode;

  ThemeState({required this.themeMode});

  ThemeState copyWith({ThemeMode? themeMode}) {
    return ThemeState(themeMode: themeMode ?? this.themeMode);
  }
}

class ThemeController extends Notifier<ThemeState> {
  @override
  ThemeState build() {
    return ThemeState(themeMode: ThemeMode.light);
  }

  Future<void> toggleTheme() async {
    // Determine the opposite theme
    final newThemeMode = state.themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;

    // PERSISTENCE: Save the selection as an integer (0 for system, 1 for light, 2 for dark)
    // index is a built-in property of Enums in Dart.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', newThemeMode.index);

    // UPDATE UI: Replace the old state with the new one
    state = state.copyWith(themeMode: newThemeMode);
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();

    // Default to 0 (which is ThemeMode.system or light depending on setup)
    final themeIndex = prefs.getInt('theme_mode') ?? 0;

    // Convert the integer back into a proper Flutter ThemeMode
    final themeMode = ThemeMode.values[themeIndex];

    state = state.copyWith(themeMode: themeMode);
  }
}
