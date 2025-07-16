import 'package:flutter/material.dart';
import 'package:school_forum/Authentication/LoginPage.dart';
import 'package:school_forum/Authentication/RegisterPage.dart';

class TogglePage extends StatefulWidget {
  const TogglePage({super.key});

  @override
  State<TogglePage> createState() => TogglePageState();
}

class TogglePageState extends State<TogglePage> {
  bool showLoginPage = true;

  void toggleScreens() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return Loginpage(onTap: toggleScreens);
    } else {
      return RegisterPage(onTap: toggleScreens);
    }
  }
}
