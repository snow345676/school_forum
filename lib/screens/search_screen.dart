import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:school_forum/screens/user_profile_screen.dart';
import 'chat_next_screen.dart';
import 'home_screen.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final Color shadowColor = const Color(0xFF084A59);
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchTerm = "";
  Timer? _debounce;
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final CollectionReference usersRef =
  FirebaseFirestore.instance.collection("users");

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() {
        _searchTerm = value.trim();
      });
    });
  }

  bool _isValidImageUrl(String value) {
    return value.startsWith("http");
  }

  Widget _buildAvatar(String avatarField) {
    if (avatarField.isEmpty) {
      return const CircleAvatar(
        backgroundImage: NetworkImage("https://sl.bing.net/b5Z2jTtlUKy"),
      );
    }

    if (_isValidImageUrl(avatarField)) {
      return CircleAvatar(
        backgroundImage: NetworkImage(avatarField),
      );
    }

    try {
      return CircleAvatar(
        backgroundImage: MemoryImage(base64Decode(avatarField)),
      );
    } catch (_) {
      return const CircleAvatar(
        backgroundImage: NetworkImage("https://sl.bing.net/b5Z2jTtlUKy"),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()));
          },
        ),
        title: const Text("Search Users", style: TextStyle(color: Colors.white)),
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
                filled: true,
                fillColor: Colors.grey[300],
                hintText: "Search by username...",
                prefixIcon: Icon(Icons.person, color: shadowColor),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear, color: shadowColor),
                  onPressed: () {
                    _searchController.clear();
                    if (!mounted) return;
                    setState(() {
                      _searchTerm = '';
                    });
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: shadowColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: shadowColor, width: 2.0),
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),

          // User list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: (_searchTerm.isEmpty)
                  ? usersRef
                  .where(FieldPath.documentId, isNotEqualTo: currentUser?.uid)
                  .orderBy("username")
                  .limit(20)
                  .snapshots()
                  : usersRef
                  .where(FieldPath.documentId, isNotEqualTo: currentUser?.uid)
                  .orderBy("username")
                  .startAt([_searchTerm])
                  .endAt(['$_searchTerm\uf8ff'])
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
                    final userData = userDoc.data()! as Map<String, dynamic>;
                    final userId = userDoc.id;
                    final username = userData['username'] ?? 'Unknown';
                    final avatarBase64 = userData['avatar_base64'] ?? '';
                    final userState = userData['state'] ?? 'offline';

                    return ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UserProfilePage(userId: userId)
                          ),
                        );
                      },
                      leading: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          _buildAvatar(avatarBase64),
                        ],
                      ),
                      title: Text(username,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          )),
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
