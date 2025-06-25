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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(10)
        ),
        padding: const EdgeInsets.all(15),
        child: Center(
          child: Text(text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20
          ),
          ),
        ),
      ),

    );
  }
}
