import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// State notifier to manage app theme switching (Light/Dark)
/// and persist the settings locally using SharedPreferences.
class ThemeNotifier extends ChangeNotifier {
  static const String _themeKey = 'is_dark_mode';
  final SharedPreferences _prefs;
  late bool _isDarkMode;

  ThemeNotifier(this._prefs) {
    // Retrieve theme preference, default to false (Light Mode) as specified
    _isDarkMode = _prefs.getBool(_themeKey) ?? false;
  }

  /// Returns true if dark mode is active
  bool get isDarkMode => _isDarkMode;

  /// Returns the matching ThemeMode
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  /// Toggles the theme state and saves the choice locally
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    await _prefs.setBool(_themeKey, _isDarkMode);
  }
}
