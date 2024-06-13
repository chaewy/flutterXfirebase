

import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
  colorScheme: ColorScheme.dark(
    primary: Colors.white, // Button and icon color in dark mode
    onPrimary: Colors.black, // Text color on top of the primary color
    background: Colors.grey.shade900,
    surface: Colors.grey.shade800,
    secondary: const Color.fromARGB(255, 75, 75, 75),
    onSecondary: Colors.white, // Text color on top of the secondary color
  ),
);