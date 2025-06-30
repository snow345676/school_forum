import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:school_forum/Authentication/toggleAuth.dart';
import 'package:school_forum/screens/profile.dart';

class auth extends StatefulWidget {
  const auth({super.key});

  @override
  State<auth> createState() => _authState();
}

class _authState extends State<auth> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context,snapshot) {
            //user is log in

            if(snapshot.hasData) {
              return profile();
            } else {
              //user is not log in

              return const toggle();
            }
          }),
    );
  }
}
