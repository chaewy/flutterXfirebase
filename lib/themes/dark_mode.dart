

import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
  colorScheme: ColorScheme.dark(
    primary: Color.fromARGB(255, 245, 168, 35),
    onPrimary: Colors.black, // Text color on top of the primary color
    background: const Color.fromARGB(255, 0, 0, 0),
    surface: const Color.fromARGB(255, 0, 0, 0),
    secondary: Color.fromARGB(255, 0, 0, 0),
    onSecondary: Colors.white, // Text color on top of the secondary color
  ),
);