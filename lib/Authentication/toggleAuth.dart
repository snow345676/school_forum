import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:school_forum/Authentication/LoginPage.dart';
import 'package:school_forum/Authentication/RegisterPage.dart';
import 'package:school_forum/screens/home_screen.dart';

class toggle extends StatefulWidget {
  const toggle({super.key});

  @override
  State<toggle> createState() => _toggleState();
}

class _toggleState extends State<toggle> {
bool showLoginPage = true;
  void togglePage() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }
  @override
  Widget build(BuildContext context) {
    if(FirebaseAuth.instance.currentUser != null){
      return HomeScreen();
    }
   if(showLoginPage) {
     return Loginpage(onTap: togglePage);
   } else {
     return RegisterPage(onTap: togglePage);
   }
  }
}
