

import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  colorScheme: const ColorScheme.light(
    primary: Color.fromARGB(255, 245, 168, 35), // Button and icon color in light mode
    onPrimary: Colors.white, // Text color on top of the primary color
    surface: Colors.white,
    background: Color.fromARGB(255, 247, 247, 247),
    secondary: Colors.white,
    onSecondary: Colors.black, // Text color on top of the secondary color
  ),
);