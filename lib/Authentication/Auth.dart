import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:school_forum/screens/home_screen.dart';
import 'package:school_forum/Authentication/toggleAuth.dart';

class Auth extends StatelessWidget {
  const Auth({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // If user is logged in
        if (snapshot.hasData) {
          return const HomeScreen();
        } else {
          // If not logged in, show login/register toggle page
          return const TogglePage();
        }
      },
    );
  }
}
