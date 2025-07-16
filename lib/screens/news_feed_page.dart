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

              child: FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection("User_Posts")
                    .orderBy("TimeStamp", descending: true)
                    .get(),
                builder: (context, snapshot) {
                  print(snapshot.data);
// return Text('${snapshot.data!.docs}');
                  final docs = snapshot.data!.docs;

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final post = docs[index];
                      return Post(
                        message: post['Message'],
                        user: post['UserEmail'],
                        postId: post.id,
                        likes: List<String>.from(post['Likes'] ?? []),
                        time: formatDate(post['TimeStamp']),
                      );
                    },
                  );
                },
              ),
            ),



          ],
        ),
      ),
    );
  }
}
