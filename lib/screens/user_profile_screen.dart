import 'dart:convert';  // add for base64 decode
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_forum/screens/chat_next_screen.dart';

import '../posts/post.dart';
import '../helper/helper.dart';
import '../screens/chat_screen.dart';

class UserProfilePage extends StatefulWidget {
  final String userId;

  const UserProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (doc.exists) {
        setState(() {
          userData = doc.data();
          isLoading = false;
        });
      } else {
        setState(() {
          userData = null;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        userData = null;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color mainColor = const Color(0xFF0C6F8B);
    final Color lighterColor = const Color(0xFF3AA0C9);

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (userData == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('User Profile'),
          backgroundColor: mainColor,
        ),
        body: const Center(child: Text('User not found')),
      );
    }

    // Try to get base64 avatar first
    ImageProvider? avatarImage;

    if (userData!['avatar_base64'] != null && userData!['avatar_base64'].isNotEmpty) {
      try {
        avatarImage = MemoryImage(base64Decode(userData!['avatar_base64']));
      } catch (e) {
        avatarImage = null;
      }
    }

    // If no base64 avatar, fallback to photoUrl string
    if (avatarImage == null) {
      final photoUrl = userData!['photoUrl'];
      if (photoUrl != null && photoUrl.isNotEmpty) {
        avatarImage = NetworkImage(photoUrl);
      } else {
        // Default avatar image or icon
        avatarImage = const AssetImage('assets/images/default_avatar.png');
        // or use NetworkImage for a default URL
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header with gradient background and chat icon
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [mainColor, lighterColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(35),
                bottomRight: Radius.circular(35),
              ),
            ),
            padding: const EdgeInsets.only(
                top: 40, left: 10, right: 20, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon:
                      const Icon(Icons.arrow_back, color: Colors.white, size: 26),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.message, color: Colors.white, size: 26),
                      tooltip: 'Chat',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatNextScreen(selectedUser: selectedUser)
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Profile picture and user info row
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 42,
                        backgroundColor: Colors.white,
                        backgroundImage: avatarImage,
                      ),
                      const SizedBox(width: 30),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userData!['username'] ?? 'No Name',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'UCSTT ${userData!['rollNumber'] ?? "N/A"} | ${userData!['year'] ?? "Year Unknown"}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // User's posts list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("User_Posts")
                  .where('uid', isEqualTo: widget.userId)
                  .orderBy("TimeStamp", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text("No posts found."),
                  );
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;

                    return Post(
                      message: data['Message'] ?? '',
                      user: data['username'] ?? 'Unknown',
                      postId: docs[index].id,
                      likes: List<String>.from(data['Likes'] ?? []),
                      time: formatDate(data['TimeStamp']),
                      postOwnerId: data['uid'],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
