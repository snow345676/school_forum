import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class myButtons extends StatelessWidget {
  final String text;
  final void Function()? onTap;

  const myButtons({
    required this.text,
    required this.onTap,
    super.key});

  @override
  Widget build(BuildContext context) {
    final Color mainColor = const Color(0xFF0C6F8B);      // #0C6F8B
    final Color lighterColor = const Color(0xFF3AA0C9);   // lighter blue for gradient
    final Color shadowColor = const Color(0xFF084A59);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
        color:shadowColor ,
          borderRadius: BorderRadius.circular(10)
        ),
        padding: const EdgeInsets.all(15),
        child: Center(
          child: Text(text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white
          ),
          ),
        ),
      ),

    );
  }
}
