import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:school_forum/screens/chat_next_screen.dart';
import '../posts/post.dart';
import '../helper/helper.dart';

class UserProfilePage extends StatefulWidget {
  final String userId;

  const UserProfilePage({super.key, required this.userId});

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

  ImageProvider? _buildAvatarImage(String? avatarField) {
    if (avatarField == null || avatarField.isEmpty) return null;

    if (avatarField.startsWith("http")) {
      return NetworkImage(avatarField);
    }

    try {
      return MemoryImage(base64Decode(avatarField));
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color mainColor = Color(0xFF0C6F8B);
    const Color lighterColor = Color(0xFF3AA0C9);

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (userData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("User Profile")),
        body: const Center(child: Text("User not found")),
      );
    }

    final avatarField = userData!['avatar_base64'] ?? userData!['photoUrl'] ?? '';
    final avatarImage = _buildAvatarImage(avatarField);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [mainColor, lighterColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(35),
                bottomRight: Radius.circular(35),
              ),
            ),
            padding: const EdgeInsets.only(top: 40, left: 10, right: 20, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
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
                      icon: const Icon(Icons.message, color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatNextScreen(
                              selectedUser: {
                                'uid': widget.userId,
                                'username': userData!['username'] ?? 'Unknown',
                                'avatar_base64': avatarField,
                                'state': userData!['state'] ?? 'offline',
                                'last_seen': userData!['last_seen'],
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Avatar + Info
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 42,
                        backgroundColor: Colors.white,
                        backgroundImage: avatarImage ??
                            const NetworkImage("https://www.gravatar.com/avatar/placeholder"),
                      ),
                      const SizedBox(width: 30),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userData!['username'] ?? 'No Name',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'UCSTT ${userData!['rollNumber'] ?? "N/A"} | ${userData!['year'] ?? "Year Unknown"}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
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

          const SizedBox(height: 10),

          // Posts
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
                  return const Center(child: Text("No posts found."));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    return Post(
                      message: data['Message'],
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
