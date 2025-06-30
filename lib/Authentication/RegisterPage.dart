import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:school_forum/components/myButtons.dart';
import 'package:school_forum/components/myTextField.dart';
import 'package:school_forum/helper/helper.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  String? selectedGender;
  String? selectedYear;

  void register() async {
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    if (passwordController.text != confirmPasswordController.text) {
      Navigator.pop(context);
      displayMessageToUser("Passwords do not match", context);
      return;
    }

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      Navigator.pop(context);
      print("Registration success");
    } on FirebaseAuthException catch (e) {
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
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              const Icon(Icons.school, size: 150),
              const SizedBox(height: 20),
              const Text("School Net", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              myTextField(hintText: "Username", obscureText: false, controller: usernameController),
              const SizedBox(height: 10),
              myTextField(hintText: "Email", obscureText: false, controller: emailController),
              const SizedBox(height: 10),

              // Gender Radio
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Radio<String>(
                        value: "Male",
                        groupValue: selectedGender,
                        onChanged: (value) => setState(() => selectedGender = value),
                      ),
                      const Text("Male"),
                    ],
                  ),
                  const SizedBox(width: 20), // spacing
                  Row(
                    children: [
                      Radio<String>(
                        value: "Female",
                        groupValue: selectedGender,
                        onChanged: (value) => setState(() => selectedGender = value),
                      ),
                      const Text("Female"),
                    ],
                  ),
                ],
              ),


              const SizedBox(height: 10),

              // Year Dropdown
              DropdownButtonFormField<String>(
                value: selectedYear,
                hint: const Text("Select Year"),
                items: ["1st Year", "2nd Year", "3rd Year", "4th Year", "5th Year"]
                    .map((year) => DropdownMenuItem(value: year, child: Text(year)))
                    .toList(),
                onChanged: (value) => setState(() => selectedYear = value),
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),

              const SizedBox(height: 10),

              myTextField(hintText: "Password", obscureText: true, controller: passwordController),
              const SizedBox(height: 10),
              myTextField(hintText: "Confirm Password", obscureText: true, controller: confirmPasswordController),

              const SizedBox(height: 20),
              myButtons(text: "Register", onTap: register),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account?"),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: const Text(" Login Now", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
