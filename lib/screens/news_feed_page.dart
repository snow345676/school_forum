import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:school_forum/posts/post.dart';

import '../helper/helper.dart';

class NewsFeedPage extends StatefulWidget {
  const NewsFeedPage({super.key});

  @override
  State<NewsFeedPage> createState() => _NewsFeedPageState();
}

class _NewsFeedPageState extends State<NewsFeedPage> {
  final currentUser = FirebaseAuth.instance.currentUser;
  final textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            // Feed
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("User_Posts")
                    .orderBy("Timestamp", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final post = snapshot.data!.docs[index];
                        final timestamp = post['Timestamp'];

                        String formattedTime = "Just now";
                        if (timestamp is Timestamp) {
                          formattedTime = formatDate(timestamp.toDate() as Timestamp);
                        }

                        return Post(
                          message: post['Message'] ?? '',
                          user: post['UserEmail'] ,
                          postId: post.id,
                          likes: List<String>.from(post['Likes'] ?? []),
                          time: formattedTime,
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),

            // Optional: show who is logged in
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                "Logged in as: ${currentUser?.email ?? 'Guest'}",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
