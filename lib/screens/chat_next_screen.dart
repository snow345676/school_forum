import 'dart:convert'; // for base64Decode
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatNextScreen extends StatefulWidget {
  const ChatNextScreen({super.key, required this.selectedUser});
  final Map<String, dynamic> selectedUser;

  @override
  State<ChatNextScreen> createState() => _ChatNextScreenState();
}

class _ChatNextScreenState extends State<ChatNextScreen> {
  final myId = FirebaseAuth.instance.currentUser!.uid;
  final TextEditingController chatController = TextEditingController();

  /// Helper: detect if a string is a URL
  bool _isValidImageUrl(String value) {
    return value.startsWith("http");
  }

  /// Get last seen text
  String getLastseenText(dynamic lastSeenRaw) {
    if (lastSeenRaw == null) return "Last Seen Recently";
    if (lastSeenRaw is! Timestamp) return "Last Seen Recently";
    final lastSeenDate = lastSeenRaw.toDate();
    final now = DateTime.now();
    final diff = now.difference(lastSeenDate);
    if (diff.inMinutes < 1) return "Last Seen Recently";
    if (diff.inMinutes < 60) return "Last Seen ${diff.inMinutes} min ago";
    if (diff.inHours < 24) return "Last Seen ${diff.inHours} hrs ago";
    return "Last Seen ${diff.inDays} days ago";
  }

  /// Chat bubble or image
  Widget buildTextCard(String text, bool isMe) {
    return text.startsWith('http')
        ? Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(text, height: 200),
      ),
    )
        : Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isMe ? Colors.blue.shade100 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text),
    );
  }

  /// Builds avatar based on URL/base64/empty
  Widget _buildAvatar(String? avatarField, {double radius = 20}) {
    if (avatarField == null || avatarField.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage:
        const NetworkImage("https://sl.bing.net/b5Z2jTtlUKy"),
      );
    }

    if (_isValidImageUrl(avatarField)) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(avatarField),
      );
    }

    try {
      return CircleAvatar(
        radius: radius,
        backgroundImage: MemoryImage(base64Decode(avatarField)),
      );
    } catch (e) {
      print("Invalid base64, showing default");
      return CircleAvatar(
        radius: radius,
        backgroundImage:
        const NetworkImage("https://sl.bing.net/b5Z2jTtlUKy"),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sort UIDs to create a unique chat path
    final List<String> ids = [myId, widget.selectedUser['uid']];
    ids.sort();
    final chatPath = '${ids[0]}_${ids[1]}';

    final messagesRef = FirebaseFirestore.instance
        .collection("chats")
        .doc(chatPath)
        .collection("messages")
        .orderBy("timestamp", descending: true);

    // Get avatar correctly
    final avatarField = widget.selectedUser['avatar_base64'] ?? '';
    print("Avatar for ${widget.selectedUser['username']}: $avatarField");

    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          leading: Stack(
            alignment: Alignment.bottomRight,
            children: [
              _buildAvatar(avatarField, radius: 22),
              if (widget.selectedUser['state'] == 'online')
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                  ),
                )
            ],
          ),
          title: Text(widget.selectedUser['username'] ?? "Unknown"),
          subtitle: Text(
            widget.selectedUser['state'] == 'online'
                ? 'Active now'
                : getLastseenText(widget.selectedUser['last_seen']),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: messagesRef.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildAvatar(avatarField, radius: 50),
                        const SizedBox(height: 10),
                        Text(widget.selectedUser['username'] ?? "Unknown"),
                        const SizedBox(height: 10),
                        const Text('Start Chatting...')
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  reverse: true,
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final msg = docs[index].data() as Map<String, dynamic>;
                    final isMe = msg['senderId'] == myId;

                    return Padding(
                      padding: EdgeInsets.only(
                        left: isMe ? 60 : 10,
                        right: isMe ? 10 : 60,
                        top: 4,
                        bottom: 4,
                      ),
                      child: Align(
                        alignment:
                        isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: buildTextCard(msg['text'] ?? '', isMe),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Container(
              margin: const EdgeInsets.all(8),
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: chatController,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: InputBorder.none,
                      ),
                      minLines: 1,
                      maxLines: 4,
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () async {
                      final text = chatController.text.trim();
                      if (text.isEmpty) return;

                      // Send message
                      await FirebaseFirestore.instance
                          .collection("chats")
                          .doc(chatPath)
                          .collection("messages")
                          .add({
                        'senderId': myId,
                        'text': text,
                        'timestamp': FieldValue.serverTimestamp(),
                      });

                      chatController.clear();
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: const Icon(Icons.send,
                          color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
