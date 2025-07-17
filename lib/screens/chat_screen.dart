import 'dart:convert'; // for base64Decode
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'chat_next_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  User? user = FirebaseAuth.instance.currentUser;
  final CollectionReference userRef =
  FirebaseFirestore.instance.collection("users");
  late DocumentReference myRef;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    if (user != null) {
      myRef = userRef.doc(user!.uid);
      _setUserOnline();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _setUserOffline();
    super.dispose();
  }

  void _setUserOnline() {
    if (user != null) {
      myRef.set({"state": "online"}, SetOptions(merge: true));
    }
  }

  void _setUserOffline() {
    if (user != null) {
      myRef.set(
        {
          "state": "offline",
          "last_seen": FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }
  }

  Future<String> _getAvatarBase64() async {
    final doc =
    await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    return doc.data()?['avatar_base64'] ?? '';
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (user != null) {
      if (state == AppLifecycleState.resumed) {
        _setUserOnline();
      } else {
        _setUserOffline();
      }
    }
  }

  /// Detects whether a string is a valid image URL
  bool _isValidImageUrl(String value) {
    return value.startsWith("http");
  }

  @override
  Widget build(BuildContext context) {
    print("CURRENT USER: ${FirebaseAuth.instance.currentUser}");

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: userRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final users = snapshot.data!.docs.where((doc) {
              return doc.id != user!.uid; // skip yourself
            }).toList();

            if (users.isEmpty) {
              return const Center(child: Text("No other users found"));
            }

            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final eachUserData =
                users[index].data() as Map<String, dynamic>;

                final otherId = users[index].id;

                // Create chatPath using sorted UIDs
                final List<String> ids = [user!.uid, otherId]..sort();
                final chatPath = '${ids[0]}_${ids[1]}';

                // Get avatar field
                final avatarField =
                    eachUserData['avatar_base64'] ?? ''; // from Firestore
                print("Avatar for ${eachUserData['username']}: $avatarField");

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("chats")
                      .doc(chatPath)
                      .collection("messages")
                      .orderBy("timestamp", descending: true)
                      .limit(1)
                      .snapshots(),
                  builder: (context, chatSnapshot) {
                    String lastMessage = '';
                    if (chatSnapshot.hasData &&
                        chatSnapshot.data!.docs.isNotEmpty) {
                      final msg = chatSnapshot.data!.docs.first.data()
                      as Map<String, dynamic>;
                      lastMessage = msg['text'] ?? '';
                    }

                    return ListTile(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ChatNextScreen(
                              selectedUser: {
                                ...eachUserData,
                                "uid": otherId, // pass UID too
                              },
                            ),
                          ),
                        );
                      },
                      leading: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          _buildAvatar(avatarField),
                          if (eachUserData['state'] == 'online')
                            Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.green,
                              ),
                              width: 12,
                              height: 12,
                            ),
                        ],
                      ),
                      title: Text(eachUserData['username'] ?? 'Unknown'),
                      subtitle: lastMessage.startsWith('http')
                          ? Align(
                        alignment: Alignment.centerLeft,
                        child: Image.network(
                          lastMessage,
                          width: 20,
                          height: 20,
                          fit: BoxFit.cover,
                        ),
                      )
                          : Text(lastMessage),
                    );
                  },
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  /// Builds avatar image based on whether it's URL, base64, or empty
  Widget _buildAvatar(String avatarField) {
    if (avatarField.isEmpty) {
      return const CircleAvatar(
        backgroundImage: NetworkImage("https://sl.bing.net/b5Z2jTtlUKy"),
      );
    }

    // If it's a URL
    if (_isValidImageUrl(avatarField)) {
      return CircleAvatar(
        backgroundImage: NetworkImage(avatarField),
      );
    }

    // Otherwise assume it's base64
    try {
      return CircleAvatar(
        backgroundImage: MemoryImage(base64Decode(avatarField)),
      );
    } catch (e) {
      print("Invalid base64 avatar, showing default");
      return const CircleAvatar(
        backgroundImage: NetworkImage("https://sl.bing.net/b5Z2jTtlUKy"),
      );
    }
  }
}
