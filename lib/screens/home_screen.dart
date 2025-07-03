import 'package:flutter/material.dart';
import 'dart:math';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:school_forum/screens/chat_screen.dart';
import 'package:school_forum/screens/friend_request.dart';
import 'package:school_forum/screens/news_feed_page.dart';
import 'package:school_forum/screens/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import your external ProfilePage here:
import 'package:school_forum/screens/profile_page.dart';

import 'add_post_page.dart'; // <-- Adjust the path!

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double drawerValue = 0;
  int _selectedIndex = 0;
  bool _showProfile = false;

  final List<Widget> _pages = [
    NewsFeedPage(),
    profile(),
    AddPostPage(),
   ChatPage(),
    FriendRequestPage(),
  ];

  @override
  void initState() {
    super.initState();
    _loadSelectedTab();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
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

          // Drawer
          SafeArea(
            child: Container(
              width: 200.0,
              color: Colors.cyan.shade700,
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(color: Colors.cyan),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 40.0,
                          backgroundImage: NetworkImage("https://sl.bing.net/dZztI9XLI6K"),
                        ),
                        SizedBox(height: 10.0),
                        Text(
                          "Chit Snow",
                          style: TextStyle(color: Colors.white, fontSize: 20.0),
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
                                    _showProfile = false;
                                  });
                                  _saveSelectedTab(0);
                                },
                                leading: Icon(Icons.home, color: Colors.white),
                                title: Text("Home", style: TextStyle(color: Colors.white)),
                              ),
                              ListTile(
                                onTap: () {
                                  setState(() {
                                    drawerValue = 0;
                                    _showProfile = true;
                                  });
                                },
                                leading: Icon(Icons.person, color: Colors.white),
                                title: Text("Profile", style: TextStyle(color: Colors.white)),
                              ),
                              ListTile(
                                onTap: () => Navigator.pop(context),
                                leading: Icon(Icons.settings, color: Colors.white),
                                title: Text("Settings", style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        ),
                        Divider(color: Colors.white54),
                        ListTile(
                          onTap: () => Navigator.pop(context),
                          leading: Icon(Icons.logout_sharp, color: Colors.white),
                          title: Text("Log Out", style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main App Content with Profile Overlay
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: drawerValue),
            duration: Duration(milliseconds: 300),
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
                    color: Colors.white,
                    child: Scaffold(
                      appBar: AppBar(
                        title: Text("School Net"),
                        backgroundColor: Colors.cyan,
                        leading: IconButton(
                          icon: Icon(Icons.menu),
                          onPressed: () {
                            setState(() {
                              drawerValue = drawerValue == 0 ? 1 : 0;
                            });
                          },
                        ),
                      ),
                      body: Stack(
                        children: [
                          IndexedStack(
                            index: _selectedIndex,
                            children: _pages,
                          ),
                          if (_showProfile)
                            Positioned.fill(
                              child: Container(
                                color: Colors.white,
                                child: Column(
                                  children: [
                                    AppBar(
                                      title: Text("Your Profile"),
                                      backgroundColor: Colors.cyan,
                                      automaticallyImplyLeading: false,
                                      actions: [
                                        IconButton(
                                          icon: Icon(Icons.close),
                                          onPressed: () {
                                            setState(() {
                                              _showProfile = false;
                                            });
                                          },
                                        )
                                      ],
                                    ),
                                    Expanded(child: ProfilePage()),  // <-- External ProfilePage
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                      bottomNavigationBar: Container(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
                          child: GNav(
                            selectedIndex: _selectedIndex,
                            onTabChange: (index) {
                              if (index == 1) {
                                setState(() {
                                  _showProfile = true;
                                });
                              } else {
                                setState(() {
                                  _selectedIndex = index;
                                  _showProfile = false;
                                  _saveSelectedTab(index);
                                });
                              }
                            },
                            tabBorderRadius: 16,
                            gap: 8,
                            backgroundColor: Colors.white,
                            color: Colors.black,
                            activeColor: Colors.cyan,
                            tabBackgroundColor: Colors.cyan.shade100,
                            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                            tabs: const [
                              GButton(icon: Icons.home, text: 'Home'),
                              GButton(icon: Icons.person, text: 'Profile'),
                              GButton(icon: Icons.add_box, text: 'Add post'),
                              GButton(icon: Icons.chat_bubble_sharp, text: 'Chat'),
                              GButton(icon: Icons.favorite_border, text: 'Add Fri'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // Swipe Gesture
          GestureDetector(
            onHorizontalDragUpdate: (e) {
              setState(() {
                drawerValue = e.delta.dx > 0 ? 1 : 0;
              });
            },
          )
        ],
      ),
    );
  }
}
