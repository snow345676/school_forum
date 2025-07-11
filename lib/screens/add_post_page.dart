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
  final currentUser = FirebaseAuth.instance.currentUser;
  String? username;

  @override
  void initState() {
    super.initState();
    fetchUsername();
  }

  Future<void> fetchUsername() async {
    if (currentUser != null) {
      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser!.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        setState(() {
          username = doc['username'] ?? "Unknown";
        });
      }
    }
  }

  void _submitPost() async {
    String content = _textController.text.trim();
    if (content.isEmpty) return;

    final uid = currentUser?.uid;
    if (uid == null) return;

    try {
      // Fetch the user's name from Firestore
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final username = userDoc.data()?['username'] ?? "Unknown";

      // Post with username
      await FirebaseFirestore.instance.collection("User_Posts").add({
        'uid': uid,
        'username': username,
        'UserEmail': currentUser?.email,
        'Message': content,
        'TimeStamp': Timestamp.now(),
        'Likes': [],
      });

      print("Post submitted: $content");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Post submitted!")),
      );
      _textController.clear();
    } catch (e) {
      print("Error posting: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to post")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text("Create a Post",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            controller: _textController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: "What's on your mind?",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _submitPost,
            icon: const Icon(Icons.send),
            label: const Text("Post"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyan,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}
