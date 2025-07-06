import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({super.key});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final TextEditingController _textController = TextEditingController();
  final currentUser= FirebaseAuth.instance.currentUser;

  void _submitPost() {
    String content = _textController.text.trim();
    if (content.isNotEmpty) {
      // TODO: Send to Firebase
      FirebaseFirestore.instance.collection("User_Posts").add({
        'UserEmail' : currentUser?.email,
    'Message' : _textController.text,
    'TimeStamp' : Timestamp.now(),

       });
      print("Post submitted: $content");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Post submitted!")),
      );
      _textController.clear();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text("Create a Post", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          TextField(
            controller: _textController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: "What's on your mind?",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _submitPost,
            icon: Icon(Icons.send),
            label: Text("Post"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyan,
              padding: EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}
