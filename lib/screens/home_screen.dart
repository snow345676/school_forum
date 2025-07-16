import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:school_forum/Authentication/toggleAuth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:school_forum/screens/add_post_page.dart';
import 'package:school_forum/screens/chat_screen.dart';
import 'package:school_forum/screens/news_feed_page.dart';
import 'package:school_forum/screens/profile_page.dart';
import '../Theme/darkMode.dart';
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
    const ChatScreen(),
    const AddPostPage(),
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

  void logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => TogglePage()),
          (route) => false,
    );
  }

  void confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Log out"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              logout(context);
            },
            child: const Text("Log Out"),
          ),
        ],
      ),
    );
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
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [lighterColor],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
          SafeArea(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [lighterColor, mainColor],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              width: 200.0,
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  DrawerHeader(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircleAvatar(
                          radius: 40.0,
                          backgroundImage: NetworkImage("https://sl.bing.net/dZztI9XLI6K"),
                        ),
                        const SizedBox(height: 15.0),
                        Text(
                          userName ?? "Loading...",
                          style: const TextStyle(color: Colors.white, fontSize: 15.0),
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
                          onTap: () => confirmLogout(context),
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
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: drawerValue),
            duration: const Duration(milliseconds: 300),
            builder: (_, double val, __) {
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..setEntry(0, 3, 200 * val)
                  ..rotateY((pi / 6) * val),
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
                            setState(() {
                              _selectedIndex = index;
                              _saveSelectedTab(index);
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
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