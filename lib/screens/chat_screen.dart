import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class ChatScreen extends StatefulWidget {
  final Map selectedUser;

  const ChatScreen({super.key, required this.selectedUser});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser;
  DatabaseReference? chatRef;

  @override
  void initState() {
    super.initState();
    _setupChatPath();
  }

  void _setupChatPath() {
    final ids = [currentUser?.uid, widget.selectedUser['uid']]
        .whereType<String>()
        .toList();

    if (ids.length < 2) {
      debugPrint("❌ Chat UID setup failed: one or both UIDs are null.");
      return;
    }

    ids.sort(); // Ensure consistent path
    final path = 'chats/${ids[0]}_${ids[1]}';
    chatRef = FirebaseDatabase.instance.ref(path);
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty || chatRef == null) return;

    final newMessage = {
      'sender': currentUser?.uid ?? '',
      'text': message,
      'timestamp': ServerValue.timestamp,
    };

    chatRef!.push().set(newMessage);
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.selectedUser['name'] ?? 'No Name';
    final photoUrl = widget.selectedUser['photoUrl'] ??
        'https://www.pngplay.com/wp-content/uploads/12/User-Avatar-Profile-PNG-Photos.png';

    return SafeArea(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.cyan.shade50,
            child: Row(
              children: [
                const BackButton(),
                CircleAvatar(backgroundImage: NetworkImage(photoUrl)),
                const SizedBox(width: 8),
                Text(name, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),

          // Chat unavailable message
          if (chatRef == null)
            const Expanded(
              child: Center(
                child: Text(
                  "Chat is unavailable.\nMissing user information.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            )
          else
          // Message Stream
            Expanded(
              child: StreamBuilder(
                stream: chatRef!.orderByChild('timestamp').onValue,
                builder: (context, snapshot) {
                  if (snapshot.hasData &&
                      snapshot.data!.snapshot.value != null) {
                    final data = Map<String, dynamic>.from(
                        snapshot.data!.snapshot.value as Map);
                    final messages = data.values
                        .map((e) => Map<String, dynamic>.from(e))
                        .toList()
                      ..sort((a, b) =>
                          (b['timestamp'] ?? 0).compareTo(a['timestamp'] ?? 0));

                    return ListView.builder(
                      reverse: true,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        final isMe = msg['sender'] == currentUser?.uid;
                        return Align(
                          alignment: isMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8),
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 14),
                            decoration: BoxDecoration(
                              color: isMe
                                  ? Colors.cyan.shade100
                                  : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(msg['text'] ?? ''),
                          ),
                        );
                      },
                    );
                  } else {
                    return const Center(child: Text("No messages yet."));
                  }
                },
              ),
            ),

          // Message Input
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.cyan,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
