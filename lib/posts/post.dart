import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../screens/user_profile_screen.dart';

class Post extends StatefulWidget {
  final String message;
  final String user;
  final String postId;
  final String time;
  final List<String> likes;
  final String postOwnerId;

  const Post({
    super.key,
    required this.message,
    required this.user,
    required this.postId,
    required this.likes,
    required this.time,
    required this.postOwnerId,
  });

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  final Color mainColor = const Color(0xFF0C6F8B);
  final Color lighterColor = const Color(0xFF3AA0C9);
  final Color shadowColor = const Color(0xFF084A59);
  String? avatarBase64;
  final currentUser = FirebaseAuth.instance.currentUser!;
  final TextEditingController _commentTextController = TextEditingController();
  late bool isLiked;
  late int likeCount;

  @override
  void initState() {
    super.initState();
    fetchAvatar();
    isLiked = widget.likes.contains(currentUser.email);
    likeCount = widget.likes.length;
  }

  Future<void> fetchAvatar() async {
    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.postOwnerId)
        .get();

    if (doc.exists) {
      setState(() {
        avatarBase64 = doc['avatar_base64'] ?? doc['photoUrl'] ?? '';
      });
    }
  }

  ImageProvider resolveAvatar(String? avatar) {
    if (avatar == null || avatar.isEmpty) {
      return const NetworkImage("https://via.placeholder.com/150");
    }
    if (avatar.startsWith("http")) {
      return NetworkImage(avatar);
    }
    try {
      return MemoryImage(base64Decode(avatar));
    } catch (_) {
      return const NetworkImage("https://via.placeholder.com/150");
    }
  }


  Future<Map<String, String>> getCurrentUserInfo() async {
    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUser.uid)
        .get();

    final data = doc.data() ?? {};
    return {
      "username": data["username"] ?? currentUser.email ?? "Unknown",
      "avatar": data["photoUrl"] ?? data["avatar_base64"] ?? "",
    };
  }


  Future<void> createNotification({
    required String toUserId,
    required String type,
    required String postId,
  }) async {

    final senderInfo = await getCurrentUserInfo();
    final senderName = senderInfo["username"]!;
    final senderAvatar = senderInfo["avatar"]!;


    final message = type == "like"
        ? "liked your post"
        : "commented on your post";

    await FirebaseFirestore.instance
        .collection("users")
        .doc(toUserId)
        .collection("notifications")
        .add({
      "type": type,
      "postId": postId,
      "fromUserId": currentUser.uid,
      "fromUserName": senderName,
      "fromUserAvatar": senderAvatar,
      "message": "$senderName $message",
      "timestamp": FieldValue.serverTimestamp(),
    });
  }


  void toggleLike() async {
    setState(() {
      isLiked = !isLiked;
      isLiked ? likeCount++ : likeCount--;
    });

    final postRef =
    FirebaseFirestore.instance.collection('User_Posts').doc(widget.postId);

    if (isLiked) {
      // Add like
      await postRef.update({
        'Likes': FieldValue.arrayUnion([currentUser.email])
      });

      // Only notify if NOT liking your own post
      if (widget.postOwnerId != currentUser.uid) {
        await createNotification(
          toUserId: widget.postOwnerId,
          type: "like",
          postId: widget.postId,
        );
      }
    } else {
      // Remove like
      await postRef.update({
        'Likes': FieldValue.arrayRemove([currentUser.email])
      });
    }
  }


  void addComment(String commentText) async {
    if (commentText.trim().isEmpty) return;

    final senderInfo = await getCurrentUserInfo();
    final username = senderInfo["username"]!;

    // Save comment
    await FirebaseFirestore.instance
        .collection("User_Posts")
        .doc(widget.postId)
        .collection("Comments")
        .add({
      "CommentText": commentText,
      "CommentedBy": username,
      "CommentedById": currentUser.uid,
      "CommentTime": Timestamp.now(),
    });

    // Notify post owner if it's not your own post
    if (widget.postOwnerId != currentUser.uid) {
      await createNotification(
        toUserId: widget.postOwnerId,
        type: "comment",
        postId: widget.postId,
      );
    }
  }

  void showCommentDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 16,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              colors: [mainColor, lighterColor],
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
                    fontSize: 20),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _commentTextController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Write a comment...",
                  hintStyle: const TextStyle(color: Colors.white70),
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
                    child: const Text("Cancel",
                        style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: mainColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      addComment(_commentTextController.text);
                      Navigator.pop(context);
                      _commentTextController.clear();
                    },
                    child: const Text("Comment"),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection("users")
                .doc(widget.postOwnerId)
                .snapshots(),
            builder: (context, snapshot) {
              String displayUsername = widget.user;

              if (snapshot.hasData && snapshot.data!.exists) {
                final data = snapshot.data!.data() as Map<String, dynamic>;
                displayUsername = data['username'] ?? widget.user;
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UserProfilePage(userId: widget.postOwnerId),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: 25,
                      backgroundImage: resolveAvatar(avatarBase64),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Username + Time
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UserProfilePage(userId: widget.postOwnerId),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayUsername,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.time,
                            style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (widget.postOwnerId == currentUser.uid)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.black45),
                      onPressed: () async {
                        final confirm = await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Delete Post"),
                            content: const Text("Are you sure you want to delete this post?"),
                            actions: [
                              TextButton(
                                child: Text("Cancel",style: TextStyle(color: shadowColor),),
                                onPressed: () => Navigator.of(context).pop(false),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                                child: Text("Delete",style: TextStyle(color: shadowColor),),
                                onPressed: () => Navigator.of(context).pop(true),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await FirebaseFirestore.instance
                              .collection("User_Posts")
                              .doc(widget.postId)
                              .delete();
                        }
                      },
                    ),
                ],
              );

            },
          ),

          const SizedBox(height: 20),

          //  Post Message
          Text(
            widget.message,
            style: TextStyle(fontSize: 18, color: Colors.grey[800]),
          ),

          //  Like & Comment buttons
          Row(
            children: [
              Column(
                children: [
                  IconButton(
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.red : Colors.grey,
                    ),
                    onPressed: toggleLike,
                  ),
                  Text('$likeCount',
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              const SizedBox(width: 5),
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.comment, color: Colors.grey),
                    onPressed: showCommentDialog,
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('User_Posts')
                        .doc(widget.postId)
                        .collection('Comments')
                        .snapshots(),
                    builder: (context, snapshot) {
                      final count = snapshot.data?.docs.length ?? 0;
                      return Text('$count',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey));
                    },
                  ),
                ],
              ),
            ],
          ),

          // Recent Comments (live)
          // Recent Comments (live)
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
                  final comment = doc.data() as Map<String, dynamic>;
                  final commenterName = comment['CommentedBy'] ?? 'Unknown';
                  final commenterId = comment['CommentedById'] ?? '';

                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "$commenterName: ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: mainColor,
                              fontSize: 14,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                if (commenterId.isNotEmpty) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          UserProfilePage(userId: commenterId),
                                    ),
                                  );
                                }
                              },
                          ),
                          TextSpan(
                            text: comment['CommentText'],
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 14,
                            ),
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
    );
  }
}
