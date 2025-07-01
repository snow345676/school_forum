import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
        background: Colors.cyan.shade50,
        primary: Colors.cyan.shade100,
        secondary: Colors.cyan.shade400,
        inversePrimary: Colors.cyan.shade600
    ),

    textTheme: ThemeData.dark().textTheme.apply(
        bodyColor: Colors.black87,
        displayColor: Colors.cyan
    )
);
