import 'package:flutter/material.dart';
import 'package:school_forum/components/myButtons.dart';
import 'package:school_forum/components/myTextField.dart';

class Loginpage extends StatelessWidget {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  Loginpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child:
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //Icon
                Icon(
                  Icons.school,
                  size: 150),
                //App name
                Text("School Net" ,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold
                  ),
                ),

                SizedBox(height: 20),
                //email TextField
                myTextField(
                    hintText: "Email",
                    obscureText: false,
                    controller: emailController),

                SizedBox(height: 10),
                //password TextField
                myTextField(
                    hintText: "Password",
                    obscureText: true,
                    controller: passwordController),
                SizedBox(height: 10),
                //forgot Password
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text("Forgot Password?",
                    style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                //login button
                myButtons(
                    text: "Login",
                    onTap: () {}
                ),
                SizedBox(height: 10),
                //do you have account?
                Center(
                  child: Row(
                    children: [
                      Text("Do you already have an account?"),
                      Text("  Register Now",style: TextStyle(

                          fontWeight: FontWeight.bold
                      ))
                    ],
                  ),
                )

              ],
            ),
          ),

      ),
    );
  }
}
