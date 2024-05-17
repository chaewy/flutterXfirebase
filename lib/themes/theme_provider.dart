import 'package:flutter/material.dart';
import 'package:flutter_application_1/themes/dark_mode.dart';
import 'package:flutter_application_1/themes/light_mode.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _themeData = lightMode; // Start with light mode

  ThemeData get themeData => _themeData; // Return the current theme

  bool get isDarkMode => _themeData == darkMode; // Check if dark mode is active

  // Setter for the themeData, correctly updates the theme and notifies listeners
  set themeData(ThemeData theme) {
    _themeData = theme;
    notifyListeners();
  }

  // Toggle the theme between light and dark
  void toggleTheme() {
    _themeData = _themeData == lightMode ? darkMode : lightMode;
    notifyListeners();
  }
}