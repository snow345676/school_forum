import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class myTextField extends StatelessWidget {

final String hintText;
final bool obscureText;
final String labelText;
final TextEditingController controller;
  const myTextField({
    required this.hintText,
    required this.obscureText,
    required this.controller,
    required this.labelText,
    super.key});

  @override
  Widget build(BuildContext context) {
    final Color mainColor = const Color(0xFF0C6F8B);      // #0C6F8B
    final Color lighterColor = const Color(0xFF3AA0C9);   // lighter blue for gradient
    final Color shadowColor = const Color(0xFF084A59);
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color:mainColor )),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: shadowColor, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.redAccent, width: 2.0),
        ),
        labelText: labelText,
        labelStyle: TextStyle(
            color: Colors.grey[900]
        ) ,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15)
        ),
        hintText: hintText,
        hintStyle: TextStyle(fontSize: 10)
      ),
      obscureText: obscureText,

    );
  }
}
