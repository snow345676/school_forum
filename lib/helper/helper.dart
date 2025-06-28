import 'package:flutter/material.dart';


//display error

void displayMessageToUser (String message, BuildContext context) {
  showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(message),
      ));
}