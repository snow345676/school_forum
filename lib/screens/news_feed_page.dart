import 'package:flutter/material.dart';

class NewsFeedPage extends StatelessWidget {
  const NewsFeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: 10, // Replace with post list length later
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.only(bottom: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=${index + 1}"),
                  ),
                  title: Text("User ${index + 1}"),
                  subtitle: Text("Just now"),
                ),
                SizedBox(height: 10),
                Text("This is a sample post content for post ${index + 1}.", style: TextStyle(fontSize: 16)),
                SizedBox(height: 10),
                Image.network("https://source.unsplash.com/random/800x400?sig=$index"),
              ],
            ),
          ),
        );
      },
    );
  }
}
