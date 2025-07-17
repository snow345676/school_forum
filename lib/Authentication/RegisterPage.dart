import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:school_forum/components/myButtons.dart';
import 'package:school_forum/components/myTextField.dart';
import 'package:school_forum/helper/helper.dart';
import 'package:school_forum/screens/home_screen.dart';



class RegisterPage extends StatefulWidget {

  final void Function()? onTap;

  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final Color mainColor = const Color(0xFF4FB3C9);
  final Color lighterColor = const Color(0xFF6BC6EF);
  final Color shadowColor = const Color(0xFF084A59);


  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController rollNumberController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  String? selectedGender;
  String? selectedYear;
  bool _obscurePassword = true;
  String? avatarBase64;
  String? error;

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

      UserCredential? userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );


      createUserDocument(userCredential);

      Navigator.pop(context);
      print("Registration success");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      displayMessageToUser(e.code, context);
    }
  }


  Future<void> createUserDocument(UserCredential? userCredential) async {
    if (userCredential != null && userCredential.user != null) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userCredential.user!.uid)
          .set({
        'uid': userCredential.user!.uid,
        'phone': phoneController.text.trim(),
        'email': userCredential.user!.email,
        'username': usernameController.text.trim(),
        'rollNumber': rollNumberController.text.trim(),
        'gender': selectedGender,
        'year': selectedYear,
        'avatar_base64': avatarBase64 ?? '',
      });
    }
  }


  Future<void> pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        avatarBase64 = base64Encode(bytes);
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    ImageProvider? avatarImage;
    if (avatarBase64 != null) {
      avatarImage = MemoryImage(base64Decode(avatarBase64!));
    }




    return Scaffold(
      backgroundColor: Theme
          .of(context)
          .colorScheme
          .background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              if (error != null)
                Text(error!, style: const TextStyle(color: Colors.red)),
              GestureDetector(
                onTap: pickAvatar,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: avatarImage,
                  child: avatarImage == null ? Icon(Icons.person, size: 80,color: shadowColor ,) : null,
                ),
              ),
              const SizedBox(height: 18),
              const Text('Tap avatar to pick image',style: TextStyle(fontWeight: FontWeight.bold),),
              const SizedBox(height: 18),

              // Icon(
              //   Icons.mark_unread_chat_alt,
              //   size: 120,
              //   color: shadowColor,
              // ),
              // const SizedBox(height: 20),
              // const Text(
              //   "School Net",
              //   style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              // ),
              // const SizedBox(height: 30),

              myTextField(
                hintText: "Username",
                labelText: "UserName",
                obscureText: false,
                controller: usernameController,
              ),
              const SizedBox(height: 20),

              myTextField(
                hintText: "Email",
                labelText: "Email",
                obscureText: false,
                controller: emailController,
              ),
              const SizedBox(height: 20),

              // Gender Radio Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Radio<String>(
                        value: "Male",
                        activeColor: shadowColor,
                        groupValue: selectedGender,
                        onChanged: (value) =>
                            setState(() => selectedGender = value),
                      ),
                      const Text("Male", style: TextStyle(fontSize: 15)),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Row(
                    children: [
                      Radio<String>(
                        value: "Female",
                        activeColor: shadowColor,
                        groupValue: selectedGender,
                        onChanged: (value) =>
                            setState(() => selectedGender = value),
                      ),
                      const Text("Female", style: TextStyle(fontSize: 15)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // Year Dropdown
              DropdownButtonFormField<String>(
                value: selectedYear,
                hint: const Text("Select Year"),
                items: [
                  "1st Year",
                  "2nd Year",
                  "3rd Year",
                  "4th Year",
                  "5th Year"
                ]
                    .map((year) =>
                    DropdownMenuItem(value: year, child: Text(year)))
                    .toList(),
                onChanged: (value) => setState(() => selectedYear = value),
                decoration: InputDecoration(
                  labelText: "Year",
                  labelStyle: TextStyle(color: Colors.grey[900]),
                  hintStyle: const TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: shadowColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: shadowColor, width: 2),
                  ),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                ),
              ),
              const SizedBox(height: 20),

              // Roll Number
              TextField(
                controller: rollNumberController,
                decoration: InputDecoration(
                  labelText: "Roll Number",
                  labelStyle:
                  TextStyle(color: Colors.grey[900], fontSize: 15),
                  prefixText: "UCSTT-",
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: mainColor),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: shadowColor, width: 2.0),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.red),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide:
                    const BorderSide(color: Colors.redAccent, width: 2.0),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 20),

              // Phone Number
              TextField(
                keyboardType: TextInputType.phone,
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: "Phone",
                  labelStyle: TextStyle(color: Colors.grey[900]),
                  hintText: "Phone",
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixText: "09-",
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: mainColor),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: shadowColor, width: 2.0),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.red),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide:
                    const BorderSide(color: Colors.redAccent, width: 2.0),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 20),

              // Password
              TextField(
                controller: passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: "Password",
                  labelStyle: TextStyle(color: Colors.grey[900]),
                  hintText: "Password",
                  hintStyle: const TextStyle(color: Colors.grey),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: mainColor),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: shadowColor, width: 2.0),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.red),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide:
                    const BorderSide(color: Colors.redAccent, width: 2.0),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 20),

              // Confirm Password
              TextField(
                controller: confirmPasswordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: "Confirm Password",
                  labelStyle: TextStyle(color: Colors.grey[900]),
                  hintText: "Confirm Password",
                  hintStyle: const TextStyle(color: Colors.grey),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: mainColor),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: shadowColor, width: 2.0),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.red),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide:
                    const BorderSide(color: Colors.redAccent, width: 2.0),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 30),

              // Register Button
              myButtons(
                text: "Register",
                onTap: register,
              ),

              const SizedBox(height: 20),

              // Login Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account?"),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: Text(
                      "Login here",
                      style: TextStyle(
                          color: shadowColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
