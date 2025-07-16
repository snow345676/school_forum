import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:school_forum/components/myButtons.dart';
import 'package:school_forum/components/myTextField.dart';
import 'package:school_forum/helper/helper.dart';
import 'package:school_forum/screens/forgott_password.dart';

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
    final Color mainColor = const Color(0xFF0C6F8B);      // #0C6F8B
    final Color lighterColor = const Color(0xFF3AA0C9);   // lighter blue for gradient
    final Color shadowColor = const Color(0xFF084A59);

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
                    Icons.mark_unread_chat_alt,
                    size: 120,
                    color: shadowColor,
                ),

                const SizedBox(height: 25),

                // App name
                Text(
                  "School Net",
                  style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 20),

                // Email TextField
                myTextField(
                  labelText: "Email",
                    hintText: "Email",
                    obscureText: false,
                    controller: emailController),

                SizedBox(height: 20),

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
                    GestureDetector(
                      child: Text(
                        "Forgot Password?",
                        style: TextStyle(fontWeight: FontWeight.bold,color: shadowColor,),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ForgotPassword()),
                        );
                      },

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
                              color: shadowColor),
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
