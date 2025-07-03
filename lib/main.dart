import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:school_forum/Authentication/LoginPage.dart';
import 'package:school_forum/screens/home_screen.dart';
import 'package:school_forum/screens/profile_page.dart';
import 'package:school_forum/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); //  Required
  await Firebase.initializeApp();            //  Initialize Firebase
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: SplashScreen(),
    );
  }
}
