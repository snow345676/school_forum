import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:school_forum/Authentication/toggleAuth.dart';
import 'package:school_forum/screens/home_screen.dart';
import 'package:school_forum/screens/profile_page.dart';
import 'package:school_forum/screens/setting_page.dart';
import 'package:school_forum/screens/splash_screen.dart';

import 'Theme/darkMode.dart';
import 'components/notification_listener.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final Color mainColor = const Color(0xFF0C6F8B);
    final Color lighterColor = const Color(0xFF3AA0C9);
    final Color shadowColor = const Color(0xFF084A59);

    return MaterialApp(
      title: 'School Forum',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "libre",
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: mainColor,
          selectionColor: lighterColor.withOpacity(0.3),
          selectionHandleColor: mainColor,
        ),
        progressIndicatorTheme: ProgressIndicatorThemeData(
          color: lighterColor,
        ),
      ),
      darkTheme: darkMode,
      themeMode: ThemeMode.system,

      home: NotificationListenerWidget(
        child: HomeScreen(),
      ),
    );
  }
}
