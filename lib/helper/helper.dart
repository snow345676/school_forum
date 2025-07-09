import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


//display error

void displayMessageToUser (String message, BuildContext context) {
  showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(message),
      ));

  //return a formatted data as a string
}
String formatDate(Timestamp timestamp){
  //Timestamp is the object restrieve from firebase
  //convert to a String
  DateTime dateTime=timestamp.toDate();

  //get year
  String year=dateTime.year.toString();


  //get month
  String month=dateTime.month.toString();


  //get day
  String day=dateTime.day.toString();

  //final formatted date
  String formattedDate ='$day/$month/$year';

  return formattedDate;

}
/*String formatDate(DateTime dateTime) {
  String year = dateTime.year.toString();
  String month = dateTime.month.toString().padLeft(2, '0');
  String day = dateTime.day.toString().padLeft(2, '0');

  return '$day/$month/$year';
}*/