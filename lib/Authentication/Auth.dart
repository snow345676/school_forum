import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:school_forum/screens/home_screen.dart';
import 'package:school_forum/Authentication/toggleAuth.dart';

import '../components/notification_listener.dart';

class Auth extends StatelessWidget {
  const Auth({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {

          return NotificationListenerWidget(child: HomeScreen());
        } else {
          return const TogglePage();
        }
      },
    );
  }
}
