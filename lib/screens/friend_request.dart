import 'package:flutter/material.dart';

class FriendRequestPage extends StatelessWidget {
  const FriendRequestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> requests = [
      "Gloria",
      "Chopra",
      "Ni Ni Chit Eain",
      "Ei Thu",
    ]; // Replace with Firebase later

    return ListView.builder(
      itemCount: requests.length,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=${index + 20}"),
            ),
            title: Text(requests[index]),
            subtitle: Text("sent you a friend request"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.check_circle, color: Colors.green),
                  onPressed: () {

                  },
                ),
                IconButton(
                  icon: Icon(Icons.cancel, color: Colors.red),
                  onPressed: () {

                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
