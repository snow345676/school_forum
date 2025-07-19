import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:school_forum/screens/search_screen.dart';
import 'package:school_forum/screens/user_profile_screen.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  // Helper: Validate image URL
  bool _isValidImageUrl(String url) {
    return url.startsWith("http://") || url.startsWith("https://");
  }

  //  Avatar resolver with proper fallback
  ImageProvider resolveAvatar(String? avatar) {
    if (avatar == null || avatar.isEmpty) {
      return const NetworkImage(
        "https://via.placeholder.com/150", //  valid fallback image
      );
    }
    if (_isValidImageUrl(avatar)) {
      return NetworkImage(avatar);
    }
    try {
      return MemoryImage(base64Decode(avatar));
    } catch (_) {
      return const NetworkImage("https://via.placeholder.com/150");
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text("Not logged in")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Notifications",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SearchPage()),
              );
            },
          ),
        ],
      ),

      // Stream of notifications
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(currentUser.uid)
            .collection("notifications")
            .orderBy("timestamp", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No notifications yet.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final notifications = snapshot.data!.docs;

          return ListView.separated(
            itemCount: notifications.length,
            separatorBuilder: (_, __) =>
                Divider(height: 1, color: Colors.grey.shade300),
            itemBuilder: (context, index) {
              final notif = notifications[index].data() as Map<String, dynamic>;

              final type = notif["type"] ?? "unknown";
              final fromUserId = notif["fromUserId"] ?? "";
              final postId = notif["postId"] ?? "";
              final timestamp = notif["timestamp"] is Timestamp
                  ? notif["timestamp"] as Timestamp
                  : null;

              final timeString = timestamp != null
                  ? DateFormat('MMM d, h:mm a').format(timestamp.toDate())
                  : "Just now";

              final storedMessage = notif["message"] ?? "No message";
              final fallbackUsername = notif["fromUser"] ?? "Unknown";

              // OLD notifications → no UID → just show stored message
              if (fromUserId.isEmpty) {
                return ListTile(
                  leading: const CircleAvatar(
                    backgroundImage:
                    NetworkImage("https://via.placeholder.com/150"),
                  ),
                  title: Text(
                    storedMessage,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    timeString,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  trailing: Icon(
                    type == "like"
                        ? Icons.favorite
                        : type == "comment"
                        ? Icons.comment
                        : Icons.notifications,
                    color: type == "like" ? Colors.pink : Colors.blue,
                  ),
                );
              }

              //  NEW notifications → Fetch sender profile
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection("users")
                    .doc(fromUserId)
                    .get(),
                builder: (context, userSnapshot) {
                  String username = fallbackUsername;
                  String avatar = "";

                  if (userSnapshot.hasData && userSnapshot.data!.exists) {
                    final userData =
                    userSnapshot.data!.data() as Map<String, dynamic>;
                    username = userData["username"] ?? fallbackUsername;
                    avatar =
                        userData["photoUrl"] ?? userData["avatar_base64"] ?? "";
                  }

                  //  Avoid double username like "Snow • Snow liked your post"
                  final displayMessage = storedMessage.contains(username)
                      ? storedMessage
                      : "$username $storedMessage";

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: resolveAvatar(avatar),
                    ),
                    title: Text(
                      displayMessage,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      timeString,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                    trailing: Icon(
                      type == "like"
                          ? Icons.favorite
                          : type == "comment"
                          ? Icons.comment
                          : Icons.notifications,
                      color: type == "like" ? Colors.pink : Colors.blue,
                    ),
                    onTap: () {
                      //  Navigate to sender profile
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UserProfilePage(userId: fromUserId),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
