import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import 'package:school_forum/screens/add_post_page.dart';
import 'package:school_forum/screens/chat_screen.dart';
import 'package:school_forum/screens/friend_request.dart';
import 'package:school_forum/screens/news_feed_page.dart';
import 'package:school_forum/screens/profile_page.dart';

import '../components/3d_appbar.dart';
import '../components/home_button_nav.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double drawerValue = 0;
  int _selectedIndex = 0;
  String? userName;
  bool isLoading = true;

  final List<Widget> _pages = [
    const NewsFeedPage(),
    // Placeholder for Profile navigation handled separately
    const AddPostPage(),
    ChatScreen(),
    const FriendRequestPage(),
  ];

  @override
  void initState() {
    super.initState();
    _loadSelectedTab();
    fetchUserName();
  }

  Future<void> _loadSelectedTab() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedIndex = prefs.getInt('selectedTab') ?? 0;
    });
  }

  Future<void> _saveSelectedTab(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedTab', index);
  }

  Future<void> fetchUserName() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();

    if (doc.exists) {
      setState(() {
        userName = doc.data()?['username'] ?? 'No Name';
        isLoading = false;
      });
    } else {
      setState(() {
        userName = 'No Name';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient behind drawer
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.cyan.shade50,
                  Colors.cyan.shade100,
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),

          // Drawer content (left menu)
          SafeArea(
            child: Container(
              width: 200.0,
              color: Colors.cyan.shade700,
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  DrawerHeader(
                    decoration: const BoxDecoration(color: Colors.cyan),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircleAvatar(
                          radius: 40.0,
                          backgroundImage: NetworkImage("https://sl.bing.net/dZztI9XLI6K"),
                        ),
                        const SizedBox(height: 10.0),
                        Text(
                          userName ?? "Loading...",
                          style: const TextStyle(color: Colors.white, fontSize: 20.0),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView(
                            children: [
                              ListTile(
                                onTap: () {
                                  setState(() {
                                    drawerValue = 0;
                                    _selectedIndex = 0;
                                  });
                                  _saveSelectedTab(0);
                                },
                                leading: const Icon(Icons.home, color: Colors.white),
                                title: const Text("Home", style: TextStyle(color: Colors.white)),
                              ),
                              ListTile(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const ProfilePage()),
                                  );
                                },
                                leading: const Icon(Icons.person, color: Colors.white),
                                title: const Text("Profile", style: TextStyle(color: Colors.white)),
                              ),
                              ListTile(
                                onTap: () => Navigator.pop(context),
                                leading: const Icon(Icons.settings, color: Colors.white),
                                title: const Text("Settings", style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        ),
                        const Divider(color: Colors.white54),
                        ListTile(
                          onTap: () => Navigator.pop(context),
                          leading: const Icon(Icons.logout_sharp, color: Colors.white),
                          title: const Text("Log Out", style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main content with 3D transform & gradient background
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: drawerValue),
            duration: const Duration(milliseconds: 300),
            builder: (_, double val, __) {
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001) // perspective
                  ..setEntry(0, 3, 200 * val) // horizontal translation
                  ..rotateY((pi / 6) * val), // rotation
                child: GestureDetector(
                  onTap: () {
                    if (drawerValue == 1) {
                      setState(() {
                        drawerValue = 0;
                      });
                    }
                  },
                  child: Material(
                    borderRadius: BorderRadius.circular(16),
                    elevation: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [
                            Colors.grey.shade400,
                            Colors.grey.shade200,
                            Colors.grey.shade100,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            offset: const Offset(0, 4),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Scaffold(
                        backgroundColor: Colors.transparent,
                        appBar: Custom3DAppBar(
                          onMenuPressed: () {
                            setState(() {
                              drawerValue = drawerValue == 0 ? 1 : 0;
                            });
                          },
                          onProfilePressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ProfilePage()),
                            );
                          },
                        ),
                        body: IndexedStack(
                          index: _selectedIndex,
                          children: _pages,
                        ),
                        bottomNavigationBar: HomeBottomNavBar(
                          selectedIndex: _selectedIndex,
                          onTabChange: (index) {
                            if (index == 1) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ProfilePage()),
                              );
                            } else {
                              setState(() {
                                _selectedIndex = index;
                                _saveSelectedTab(index);
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // Gesture to drag open/close drawer
          GestureDetector(
            onHorizontalDragUpdate: (e) {
              setState(() {
                drawerValue = e.delta.dx > 0 ? 1 : 0;
              });
            },
          ),
        ],
      ),
    );
  }
}
