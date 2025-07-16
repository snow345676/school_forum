import 'package:flutter/material.dart';

final Color mainColor = Color(0xFF0C6F8B);
final Color lighterColor = Color(0xFF3AA0C9);
final Color shadowColor = Color(0xFF084A59);

final ThemeData lightMode = ThemeData(
    brightness: Brightness.light,
    fontFamily: "Libre",
    colorScheme: ColorScheme.light(
        background: Colors.grey.shade50,
        primary: mainColor,
        secondary: lighterColor,
        inversePrimary: shadowColor,
    ),
    textTheme: ThemeData.light().textTheme.apply(
        bodyColor: Colors.black87,
        displayColor: Colors.cyan,
    ),


    progressIndicatorTheme: ProgressIndicatorThemeData(
        color: lighterColor,
    ),

    textSelectionTheme: TextSelectionThemeData(
        cursorColor: mainColor,
        selectionColor: lighterColor.withOpacity(0.3),
        selectionHandleColor: mainColor,
    ),
);
