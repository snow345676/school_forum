import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:school_forum/components/comment_button.dart';
import 'package:school_forum/components/like_button.dart';


class Post extends StatefulWidget {
  final String message;
  final String user;
  final String postId;
  final String time;
  final List<String> likes;

  const Post({
    super.key,
    required this.message,
    required this.user,
    required this.postId,
    required this.likes,
    required this.time,
  });

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  String? username;
  final currentUser = FirebaseAuth.instance.currentUser!;
  final TextEditingController _commentTextController = TextEditingController();
  late bool isLiked;
  late int likeCount;

  final Color mainColor = const Color(0xFF0C6F8B);
  final Color lighterColor = const Color(0xFF3AA0C9);
  final Color shadowColor = const Color(0xFF084A59);

  @override
  void initState() {
    fetchUsername();
    super.initState();
    isLiked = widget.likes.contains(currentUser.email);
    likeCount = widget.likes.length;
  }

  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
      isLiked ? likeCount++ : likeCount--;
    });

    DocumentReference postRef =
    FirebaseFirestore.instance.collection('User_Posts').doc(widget.postId);

    if (isLiked) {
      postRef.update({
        'Likes': FieldValue.arrayUnion([currentUser.email])
      });
    } else {
      postRef.update({
        'Likes': FieldValue.arrayRemove([currentUser.email])
      });
    }
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

  void addComment(String commentText) {
    if (commentText.trim().isEmpty) return;
    FirebaseFirestore.instance
        .collection("User_Posts")
        .doc(widget.postId)
        .collection("Comments")
        .add({
      "CommentText": commentText,
      "CommentedBy": username,
      "CommentTime": Timestamp.now(),
    });
  }

  void showCommentDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 16,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              colors: [
                mainColor,lighterColor  // Lighter cyan
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),

          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Add Comment",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,

                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _commentTextController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Write a comment...",
                  hintStyle: TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _commentTextController.clear();
                    },
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Color(0xFF0C6F8B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      addComment(_commentTextController.text);
                      Navigator.pop(context);
                      _commentTextController.clear();
                    },
                    child: const Text("Post",style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: Likes and Comments

          Column(
            children: [
              LikeButton(isLiked: isLiked, onTap: toggleLike),
              const SizedBox(height: 4),
              Text('$likeCount', style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 10),
              CommentButton(onTap: showCommentDialog),
              const SizedBox(height: 4),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('User_Posts')
                    .doc(widget.postId)
                    .collection('Comments')
                    .snapshots(),
                builder: (context, snapshot) {
                  int count = 0;
                  if (snapshot.hasData) {
                    count = snapshot.data!.docs.length;
                  }
                  return Text('$count', style: const TextStyle(color: Colors.grey));
                },
              ),
            ],
          ),
          const SizedBox(width: 16),

          // Right: User, Time, Message, Comments
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Username and time
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.user,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                    Text(
                      widget.time,
                      style: TextStyle(
                          color: Colors.grey[900],
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Message
                Text(
                  widget.message,
                  style: const TextStyle(fontSize: 19),
                ),
                const SizedBox(height: 12),

                // Comment List
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("User_Posts")
                      .doc(widget.postId)
                      .collection("Comments")
                      .orderBy("CommentTime", descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox();

                    return ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: snapshot.data!.docs.map((doc) {
                        final commentData = doc.data() as Map<String, dynamic>;
                        final commentUser = commentData["CommentedBy"] ?? '';
                        final commentText = commentData["CommentText"] ?? '';

                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "$commentUser: ",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: mainColor,
                                  ),
                                ),
                                TextSpan(
                                  text: commentText,
                                  style:TextStyle(color: Colors.grey[700]),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );

                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
