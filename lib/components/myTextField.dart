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
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
            color: Colors.grey[800]
        ) ,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10)
        ),
        hintText: hintText,
      ),
      obscureText: obscureText,

    );
  }
}
