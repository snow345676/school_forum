import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:school_forum/components/myButtons.dart';
import 'package:school_forum/components/myTextField.dart';
import 'package:school_forum/helper/helper.dart';
import 'package:school_forum/screens/home_screen.dart';
import 'package:school_forum/screens/profile.dart';



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
  final TextEditingController rollNumberController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

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
      //create user
      UserCredential? userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      //create a user document and add to firestore
      createUserDocument(userCredential);

      Navigator.pop(context);
      print("Registration success");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      displayMessageToUser(e.code, context);
    }
  }

  //create a user document and collect them in firestore
  Future<void> createUserDocument(UserCredential? userCredential) async {
    if(userCredential != null && userCredential.user != null) {
      await FirebaseFirestore.instance.collection("users").doc(userCredential.user!.email).set(
          {
            'uid' : userCredential.user!.uid,
            'phone' : phoneController.text,
            'email': userCredential.user!.email,
            'username': usernameController.text,
            'rollNumber': rollNumberController.text,
            'gender': selectedGender,
            'year' : selectedYear,
            'photoUrl' :userCredential.user!.photoURL,
          });
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
              Icon(
                Icons.school,
                size: 150,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              const SizedBox(height: 20),
              const Text("School Net", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              myTextField(hintText: "Username",labelText: "UserName", obscureText: false, controller: usernameController),
              const SizedBox(height: 10),
              myTextField(hintText: "Email", labelText: "Email", obscureText: false, controller: emailController),
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


              const SizedBox(height: 15),

              // Year Dropdown
              DropdownButtonFormField<String>(
                value: selectedYear,
                hint: const Text("Select Year"),
                items: ["1st Year", "2nd Year", "3rd Year", "4th Year", "5th Year"]
                    .map((year) => DropdownMenuItem(value: year, child: Text(year)))
                    .toList(),
                onChanged: (value) => setState(() => selectedYear = value),
                decoration: InputDecoration(
                  labelText: "Year",
                  labelStyle: TextStyle(
                      color: Colors.grey[800]
                  ) ,
                  hintText: "Select Year",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10), // Match TextField
                  ),
                  // enabledBorder: OutlineInputBorder(
                  //   borderRadius: BorderRadius.circular(10),
                  //   borderSide: BorderSide(color: Colors.grey),
                  // ),
                  // focusedBorder: OutlineInputBorder(
                  //   borderRadius: BorderRadius.circular(10),
                  //   borderSide: BorderSide(color: Colors.cyan, width: 2),
                  // ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: rollNumberController,
                decoration: InputDecoration(
                  labelText: "Roll Number",
                  labelStyle: TextStyle(
                      color: Colors.grey[800]
                  ) ,
                  prefixText: "UCSTT-",

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),

              TextField(
                keyboardType: TextInputType.phone,
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: "Phone",
                  labelStyle: TextStyle(
                      color: Colors.grey[800]
                  ) ,
                  prefixText: "09-",

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),





              const SizedBox(height: 15),

              myTextField(hintText: "Password",labelText: "Password", obscureText: true, controller: passwordController),
              const SizedBox(height: 15),
              myTextField(hintText: "Confirm Password",labelText: "Confirm Password", obscureText: true, controller: confirmPasswordController),

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
