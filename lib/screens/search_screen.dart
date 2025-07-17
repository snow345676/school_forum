import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../screens/user_profile_screen.dart';
import 'home_screen.dart';


class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String searchTerm = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()));
            },
        ),
        title: const Text("Search Users"),
        backgroundColor: const Color(0xFF0C6F8B),

      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              focusNode: _searchFocusNode,
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search by username...",
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchTerm = value.trim();
                });
              },
            ),
          ),

          // List of filtered users
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: searchTerm.isEmpty
                  ? FirebaseFirestore.instance
                  .collection("users")
                  .orderBy("username")
                  .limit(10)
                  .snapshots()
                  : FirebaseFirestore.instance
                  .collection("users")
                  .orderBy("username")
                  .startAt([searchTerm])
                  .endAt([searchTerm + '\uf8ff'])
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No users found"));
                }

                final users = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final userDoc = users[index];
                    final username = userDoc['username'];
                    final userId = userDoc.id;

                    return ListTile(
                      leading: const Icon(Icons.account_circle, color: Color(0xFF0C6F8B)),
                      title: Text(username),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UserProfilePage(userId: userId),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
