import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
        background: Colors.grey.shade200,
        primary: Colors.deepPurple.shade300,
        secondary: Colors.deepPurple.shade400,
        inversePrimary: Colors.grey.shade800
    ),

    textTheme: ThemeData.dark().textTheme.apply(
        bodyColor: Colors.grey[800],
        displayColor: Colors.deepPurple
    )
);
