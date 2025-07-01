import 'package:flutter/material.dart';
import 'package:school_forum/Authentication/LoginPage.dart';
import 'package:school_forum/Authentication/RegisterPage.dart';

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
   if(showLoginPage) {
     return Loginpage(onTap: togglePage);
   } else {
     return RegisterPage(onTap: togglePage);
   }
  }
}
