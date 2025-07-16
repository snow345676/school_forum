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
  final CollectionReference userRef = FirebaseFirestore.instance.collection("users");
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

  @override
  Widget build(BuildContext context) {
    print("CURRENT USER: ${FirebaseAuth.instance.currentUser}");

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: userRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            //  Don't filter by userId field, just use doc.id
            final users = snapshot.data!.docs.where((doc) {
              return doc.id != user!.uid; // skip yourself
            }).toList();

            if (users.isEmpty) {
              return const Center(child: Text("No other users found"));
            }

            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final eachUserData = users[index].data() as Map<String, dynamic>;

                //  doc.id is the other user UID
                final otherId = users[index].id;

                //  Create chatPath using sorted UIDs
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
                          CircleAvatar(
                            backgroundImage: NetworkImage(
                              eachUserData['photoUrl'] ??
                                  'https://sl.bing.net/b5Z2jTtlUKy',
                            ),
                          ),
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
}
