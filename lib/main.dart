
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:school_forum/Authentication/toggleAuth.dart';
import 'package:school_forum/Theme/darkMode.dart';
import 'package:school_forum/firebase_options.dart';
import 'package:school_forum/screens/splash_screen.dart';


import 'Theme/lightMode.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'School Forum',
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
      theme: lightMode,
      darkTheme: darkMode,
      // routes: {
      //   "/auth" : (context) => auth(),
      //   "/profile": (context) => profile()
      // },
    );

  }
}


