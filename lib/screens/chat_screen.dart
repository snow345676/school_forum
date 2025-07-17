import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:school_forum/Theme/darkMode.dart';
import 'chat_next_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final User? user = FirebaseAuth.instance.currentUser;
  final CollectionReference userRef =
  FirebaseFirestore.instance.collection("users");

  String searchQuery = "";
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
      myRef.set({
        "state": "offline",
        "last_seen": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  bool _isValidImageUrl(String value) => value.startsWith("http");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(15),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              onChanged: (value) {
                setState(() => searchQuery = value.toLowerCase());
              },
              decoration: InputDecoration(
                hintText: "Search by username...",
                filled: true,
                fillColor: Colors.grey[300],
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: userRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final users = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final username = (data['username'] ?? '').toString().toLowerCase();
            return doc.id != user!.uid && username.contains(searchQuery);
          }).toList();

          if (users.isEmpty) return const Center(child: Text("No users found"));

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userDoc = users[index];
              final data = userDoc.data() as Map<String, dynamic>;
              final otherId = userDoc.id;
              final avatarField = data['avatar_base64'] ?? '';
              final List<String> ids = [user!.uid, otherId]..sort();
              final chatPath = '${ids[0]}_${ids[1]}';

              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("chats")
                    .doc(chatPath)
                    .collection("messages")
                    .orderBy("timestamp", descending: true)
                    .limit(1)
                    .snapshots(),
                builder: (context, chatSnapshot) {
                  String lastMessage = "";
                  if (chatSnapshot.hasData &&
                      chatSnapshot.data!.docs.isNotEmpty) {
                    final msg = chatSnapshot.data!.docs.first.data()
                    as Map<String, dynamic>;
                    lastMessage = msg['text'] ?? '';
                  }

                  return ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatNextScreen(
                            selectedUser: {
                              ...data,
                              "uid": otherId,
                            },
                          ),
                        ),
                      );
                    },
                    leading: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        _buildAvatar(avatarField),
                        if (data['state'] == 'online')
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                      ],
                    ),
                    title: Text(data['username'] ?? 'Unknown'),
                    subtitle: lastMessage.startsWith('http')
                        ? Image.network(lastMessage, width: 20, height: 20)
                        : Text(lastMessage),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAvatar(String avatarField) {
    if (avatarField.isEmpty) {
      return const CircleAvatar(
        backgroundImage: NetworkImage("https://sl.bing.net/b5Z2jTtlUKy"),
      );
    }

    if (_isValidImageUrl(avatarField)) {
      return CircleAvatar(backgroundImage: NetworkImage(avatarField));
    }

    try {
      return CircleAvatar(backgroundImage: MemoryImage(base64Decode(avatarField)));
    } catch (_) {
      return const CircleAvatar(
        backgroundImage: NetworkImage("https://sl.bing.net/b5Z2jTtlUKy"),
      );
    }
  }
}
