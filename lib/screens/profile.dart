import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:school_forum/Authentication/Auth.dart';

class profile extends StatelessWidget {
  profile({super.key});

  //current log in user
  User? currentUser = FirebaseAuth.instance.currentUser;


  // future to fetch user details
  Future<DocumentSnapshot<Map<String,dynamic>>> getUserDetails() async {
  return await FirebaseFirestore.instance.collection("users").doc(currentUser!.email).get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:Text("Profile") ,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: FutureBuilder(
          future: getUserDetails(),
          builder: (context, snapshot) {
            //loading
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            //error
            else if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            }
            //data received
            else if (snapshot.hasData) {
              Map<String,dynamic>? user = snapshot.data!.data();

              return Center(
                child: Column(
                  children: [
                    Text(user!['email']),
                    Text(user!['username']),

                  ],
                ),
              );
            } else {
              return Text("No data");
            }
    },
    )
    );
  }
}
