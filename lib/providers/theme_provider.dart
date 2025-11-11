import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  bool _isInitialized = false;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isInitialized => _isInitialized;

  ThemeProvider() {
    _initializeTheme();
  }

  void _initializeTheme() {
    try {
      final prefs = SharedPreferences.getInstance();
      prefs.then((pref) {
        final isDark = pref.getBool('isDarkMode') ?? false;
        _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
        _isInitialized = true;
        notifyListeners();
      });
    } catch (e) {
      _themeMode = ThemeMode.light;
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> toggleTheme(bool isDark) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      await prefs.setBool('isDarkMode', isDark);
      notifyListeners();
    } catch (e) {
      notifyListeners();
    }
  }
}
