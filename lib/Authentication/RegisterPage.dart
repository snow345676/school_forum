import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../components/myButtons.dart';
import '../components/myTextField.dart';
import '../helper/helper.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final List<String> year = [
    'First Year',
    'Second Year',
    'Third Year',
    'Fourth Year',
    'Fifth Year'
  ];
  String? selectedYear;
  String? selectedGender;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  void registerUser ()  async {
    //show loading circle
  showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      )
  );
    //make sure password match

    if(passwordController.text != confirmPasswordController.text) {
      Navigator.pop(context);
      //show error message to user
      displayMessageToUser("Password don't match",context);
    }
    //try creating the user
    try {
      //create user
     UserCredential? userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
         email: emailController.text.trim(),
         password: passwordController.text.trim());

  //pop loading circle
     Navigator.pop(context);
    } on
      FirebaseAuthException catch (e) {
        //pop loading circle
    
      Navigator.pop(context);
    }

  }

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
                Icon(Icons.school, size: 100),
                Text(
                  "School Net",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),

                // Name
                myTextField(
                  hintText: "Name",
                  obscureText: false,
                  controller: nameController,
                ),
                SizedBox(height: 20),

                // Email
                myTextField(
                  hintText: "Email",
                  obscureText: false,
                  controller: emailController,
                ),
                SizedBox(height: 20),
                // Phone
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)
                  ),
                  hintText: "Phone",
                ),
                obscureText: false,
                keyboardType: TextInputType.phone,
              ),

                SizedBox(height: 20),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: Text('Male'),
                            value: 'Male',
                            groupValue: selectedGender,
                            onChanged: (value) {
                              setState(() {
                                selectedGender = value;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: Text('Female'),
                            value: 'Female',
                            groupValue: selectedGender,
                            onChanged: (value) {
                              setState(() {
                                selectedGender = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),


                // Year Dropdown
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    contentPadding: EdgeInsets.all(17.0),
                  ),
                  items: year.map((year) {
                    return DropdownMenuItem(value: year, child: Text(year));
                  }).toList(),
                  value: selectedYear,
                  hint: Text("Choose year"),
                  onChanged: (newValue) {
                    setState(() {
                      selectedYear = newValue;
                    });
                  },
                  validator: (value) =>
                  value == null ? "Please select your year" : null,
                ),
                SizedBox(height: 10),

                // Password
                myTextField(
                  hintText: "Password",
                  obscureText: true,
                  controller: passwordController,
                ),
                SizedBox(height: 10),

                // Confirm Password
                myTextField(
                  hintText: "Confirm password",
                  obscureText: true,
                  controller: confirmPasswordController,
                ),
                SizedBox(height: 10),

                // Forgot Password
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Forgot password",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 10),

                // Register Button
                myButtons(
                  text: "Register",
                  onTap: () {
                    if (passwordController.text !=
                        confirmPasswordController.text) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("Passwords do not match"),
                      ));
                      return;
                    }

                    // Registration logic here...
                  },
                ),
                SizedBox(height: 15),

                // Go to Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account?"),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Text(
                        "  Login Now",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
