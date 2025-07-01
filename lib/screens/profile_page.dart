import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: NetworkImage("https://sl.bing.net/dZztI9XLI6K"),
          ),
          SizedBox(height: 20),
          Text("Chit Snow Oo", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text("Software Engineer"),
          SizedBox(height: 20),
          ListTile(
            leading: Icon(Icons.email),
            title: Text("chitsnow@ucstt.edu.mm"),
          ),
          ListTile(
            leading: Icon(Icons.location_on),
            title: Text("Thaton, Mon, Myanmar"),
          ),
        ],
      ),
    );
  }
}
