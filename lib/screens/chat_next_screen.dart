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

  String getLastseenText(Timestamp? lastSeen) {
    if (lastSeen == null) return "Last Seen Recently";
    final lastSeenDate = lastSeen.toDate();
    final now = DateTime.now();
    final diff = now.difference(lastSeenDate);
    if (diff.inMinutes < 1) return "Last Seen Recently";
    if (diff.inMinutes < 60) return "Last Seen ${diff.inMinutes} min ago";
    if (diff.inHours < 24) return "Last Seen ${diff.inHours} hrs ago";
    return "Last Seen ${diff.inDays} days ago";
  }

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
      margin: EdgeInsets.symmetric(vertical: 4),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isMe ? Colors.blue.shade100 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text),
    );
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

    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          leading: Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                backgroundImage:
                NetworkImage(widget.selectedUser['photoUrl'] ?? ''),
              ),
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
                        CircleAvatar(
                          radius: 50,
                          backgroundImage:
                          NetworkImage(widget.selectedUser['photoUrl'] ?? ''),
                        ),
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
                        left: isMe ? 60 : 10,   // more space for  messages
                        right: isMe ? 10 : 60,  // more space for other user messages
                        top: 4,
                        bottom: 4,
                      ),
                      child: Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade100, // light background
                borderRadius: BorderRadius.circular(30), // rounded corners
                border: Border.all(color: Colors.grey.shade300), // subtle border
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: chatController,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: InputBorder.none, // remove default underline
                      ),
                      minLines: 1,
                      maxLines: 4, // allow multiline
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
                      child: const Icon(Icons.send, color: Colors.white, size: 18),
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
