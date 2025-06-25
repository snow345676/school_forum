import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class myTextField extends StatelessWidget {
final String hintText;
final bool obscureText;
final TextEditingController controller;
  const myTextField({
    required this.hintText,
    required this.obscureText,
    required this.controller,
    super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10)
        ),
        hintText: hintText,
      ),
      obscureText: obscureText,
    );
  }
}
