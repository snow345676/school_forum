import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotificationListenerWidget extends StatefulWidget {
  final Widget child;

  const NotificationListenerWidget({required this.child, Key? key}) : super(key: key);

  @override
  State<NotificationListenerWidget> createState() => _NotificationListenerWidgetState();
}

class _NotificationListenerWidgetState extends State<NotificationListenerWidget> {
  StreamSubscription<QuerySnapshot>? _subscription;
  final currentUser = FirebaseAuth.instance.currentUser;
  Set<String> _shownNotificationIds = {};

  @override
  void initState() {
    super.initState();

    if (currentUser != null) {
      _subscription = FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser!.uid)
          .collection("notifications")
          .orderBy("timestamp", descending: true)
          .snapshots()
          .listen((snapshot) {
        for (var change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.added) {
            final notifId = change.doc.id;
            if (!_shownNotificationIds.contains(notifId)) {
              _shownNotificationIds.add(notifId);

              final notifData = change.doc.data();
              if (notifData != null) {
                final message = notifData['message'] ?? "You have a new notification";

                // Show SnackBar
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(message),
                      duration: const Duration(seconds: 3),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            }
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
