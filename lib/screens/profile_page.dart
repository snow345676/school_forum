import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:school_forum/screens/home_screen.dart';
import 'package:school_forum/screens/setting_page.dart';
import '../posts/post.dart';
import '../helper/helper.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  String? error;
  final currentUser = FirebaseAuth.instance.currentUser;
  final photoUrl = FirebaseAuth.instance.currentUser?.photoURL ??
      'https://www.gravatar.com/avatar/placeholder';

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      if (currentUser == null) {
        setState(() {
          error = "No user logged in";
          isLoading = false;
        });
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .get();

      if (!doc.exists) {
        setState(() {
          error = "User document not found";
          isLoading = false;
        });
        return;
      }

      setState(() {
        userData = doc.data();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = "Failed to load user data: $e";
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

    if (error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile', style: TextStyle(fontSize: 20))),
        body: Center(child: Text(error!)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header
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
            padding: const EdgeInsets.only(top: 40, left: 10, right: 20, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const HomeScreen()),
                            );
                          },
                        ),
                        const SizedBox(width: 30),
                        const Text(
                          'Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white, size: 28),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const SettingPage()),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 20),


                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      // Profile Picture
                      CircleAvatar(
                        radius: 42,
                        backgroundColor: Colors.white,
                        backgroundImage: NetworkImage(photoUrl),
                      ),

                      const SizedBox(width: 30),

                      // Username info
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



          const SizedBox(height: 10),

          // Posts
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("User_Posts")
                        .where('uid', isEqualTo: currentUser!.uid)
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
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final post = docs[index];
                          final data = post.data() as Map<String, dynamic>;

                          return Post(
                            message: data['Message'],
                            user: data['username'] ?? 'Unknown',
                            postId: post.id,
                            likes: List<String>.from(data['Likes'] ?? []),
                            time: formatDate(data['TimeStamp']),
                          );
                        },
                      );
                    },
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
