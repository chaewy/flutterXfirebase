

import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.light(
    primary: Colors.black, // Button and icon color in light mode
    onPrimary: Colors.white, // Text color on top of the primary color
    surface: Colors.white,
    background: Colors.grey.shade100,
    secondary: Colors.grey.shade200,
    onSecondary: Colors.black, // Text color on top of the secondary color
  ),
);