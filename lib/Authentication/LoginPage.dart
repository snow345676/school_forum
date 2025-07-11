import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:school_forum/components/myButtons.dart';
import 'package:school_forum/components/myTextField.dart';
import 'package:school_forum/helper/helper.dart';

import '../screens/home_screen.dart';

class Loginpage extends StatefulWidget {
  final void Function()? onTap;

  Loginpage({super.key, required this.onTap});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  //text controller
  TextEditingController emailController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

  void Login() async {
    //show loading circle

    showDialog(
        context: context,
        builder: (context) => Center(
          child: CircularProgressIndicator(),
        ));


    //try sign in

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim()
      );

      print("success login");

      Navigator.pop(context);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>HomeScreen()),
      );
      //display any error
    } on FirebaseAuthException catch (e) {
      //pop loading
      Navigator.pop(context);
      displayMessageToUser(e.code, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // logo
                Icon(
                    Icons.school,
                    size: 150,
                    color: Theme.of(context).colorScheme.inversePrimary,
                ),

                const SizedBox(height: 25),

                // App name
                Text(
                  "School Net",
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 20),

                // Email TextField
                myTextField(
                  labelText: "Email",
                    hintText: "Email",
                    obscureText: false,
                    controller: emailController),

                SizedBox(height: 10),

                // Password TextField
                myTextField(
                  labelText: "Password",
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
                  onTap: Login
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
