

import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.light(
    primary: Color.fromARGB(255, 245, 168, 35), // Button and icon color in light mode
    onPrimary: Colors.white, // Text color on top of the primary color
    surface: Colors.white,
    background: const Color.fromARGB(255, 255, 255, 255),
    secondary: const Color.fromARGB(255, 255, 255, 255),
    onSecondary: Colors.black, // Text color on top of the secondary color
  ),
);