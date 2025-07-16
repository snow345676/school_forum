import 'package:flutter/material.dart';

final Color mainColor = const Color(0xFF0C6F8B);
final Color lighterColor = const Color(0xFF3AA0C9);
final Color shadowColor = const Color(0xFF084A59);

final ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,

  colorScheme: ColorScheme.dark(
    background: const Color(0xFF121212),
    primary: mainColor,
    secondary: lighterColor,
    inversePrimary: Colors.white,
  ),

  scaffoldBackgroundColor: const Color(0xFF121212),

  fontFamily: 'LibertinusMath',

  textTheme: ThemeData.dark().textTheme.apply(
    bodyColor: Colors.grey[300],       // Normal text color in dark mode
    displayColor: lighterColor,        // Headings, highlights
  ),

  progressIndicatorTheme: ProgressIndicatorThemeData(
    color: lighterColor,
  ),

  inputDecorationTheme: InputDecorationTheme(
    hintStyle: TextStyle(color: Colors.grey[500]),
    labelStyle: TextStyle(color: lighterColor),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: mainColor),
      borderRadius: BorderRadius.circular(8),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: shadowColor, width: 2),
      borderRadius: BorderRadius.circular(8),
    ),
  ),
);
