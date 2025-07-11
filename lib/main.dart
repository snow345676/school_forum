import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:school_forum/Authentication/LoginPage.dart';
import 'package:school_forum/screens/home_screen.dart';
import 'package:school_forum/screens/profile_page.dart';
import 'package:school_forum/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'School Forum',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'LibertinusMath',
      ),
      home: const SplashScreen(),
    );
  }
}
