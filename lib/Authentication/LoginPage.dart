import 'package:flutter/material.dart';
import 'package:school_forum/components/myButtons.dart';
import 'package:school_forum/components/myTextField.dart';

class Loginpage extends StatefulWidget {
  final void Function()? onTap;

  const Loginpage({super.key, required this.onTap}); // <-- Fix here

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Icon(Icons.school, size: 150),

                // App name
                Text(
                  "School Net",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 20),

                // Email TextField
                myTextField(
                    hintText: "Email",
                    obscureText: false,
                    controller: emailController),

                SizedBox(height: 10),

                // Password TextField
                myTextField(
                    hintText: "Password",
                    obscureText: true,
                    controller: passwordController),

                SizedBox(height: 10),

                // Forgot Password
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Forgot Password?",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),

                SizedBox(height: 10),

                // Login button
                myButtons(
                  text: "Login",
                  onTap: () {
                    // Add login logic here
                  },
                ),

                SizedBox(height: 15),

                // Register redirect
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account?"),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: Text(
                          "  Register Now",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
