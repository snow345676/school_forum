import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:google_nav_bar/google_nav_bar.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName='';
  String email='';
  String gender='';
  String phone='';
  String rno='';
  String year='';
  @override

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserDetail ();
  }

  Future<void> getUserDetail() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;


      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("users")
          .where("uid", isEqualTo: uid)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var userDoc = querySnapshot.docs.first;


        setState(() {
          userName = userDoc['username'] ?? '';
          email = userDoc['email'] ?? '';
          phone = userDoc['phone'] ?? '';
          gender = userDoc['gender'] ?? '';
          rno = userDoc['rollNumber'] ?? '';
          year = userDoc['year'] ?? '';
        });
      } else {
        print("User not found in Firestore");
        setState(() {
          userName = "Not found";
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }



  //fetch user details


  double value = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
      Stack(
        children: [
          // Background Gradient
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

          // Navigation Menu
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
                          userName
                          ,
                          style: TextStyle(color: Colors.white, fontSize: 20.0),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: [
                        ListTile(
                          onTap: () {},
                          leading: Icon(Icons.home, color: Colors.white),
                          title: Text("Home", style: TextStyle(color: Colors.white)),
                        ),
                        ListTile(
                          onTap: () {},
                          leading: Icon(Icons.person, color: Colors.white),
                          title: GestureDetector(
                            onTap: () {},
                              child: Text("Profile", style: TextStyle(color: Colors.white))),
                        ),
                        ListTile(
                          onTap: () {},
                          leading: Icon(Icons.settings, color: Colors.white),
                          title: Text("Settings", style: TextStyle(color: Colors.white)),
                        ),
                        ListTile(
                          onTap: () {},
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

          // Animated Main Content
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: value),
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
                    if (value == 1) {
                      setState(() {
                        value = 0;
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
                              value = value == 0 ? 1 : 0;
                            });
                          },
                        ),
                      ),
                      body: Center(child: Text("Welcome to $userName")),
                      bottomNavigationBar: Container(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 20),
                          child: GNav(
                            tabBorderRadius: 16,
                            gap: 8,
                            onTabChange: (index){
                              print(index);
                            },
                            backgroundColor: Colors.white,
                            color: Colors.black,
                            activeColor: Colors.cyan,
                            tabBackgroundColor: Colors.cyan.shade100,
                            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                            tabs: const [
                              GButton(
                                  icon: Icons.home,
                                  text: 'Home'
                              ),
                              GButton(
                                  icon: Icons.person,
                                  text: 'Profile'
                              ),
                              GButton(
                                  icon: Icons.add_box,
                                  text: 'Add post'
                              ),
                              GButton(
                                  icon: Icons.chat_bubble_sharp,
                                  text: 'Chat'
                              ),
                              GButton(
                                  icon: Icons.favorite_border,
                                  text: 'Add Fri'
                              ),
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

          // Gesture Detector for Swiping
          GestureDetector(
            onHorizontalDragUpdate: (e) {
              setState(() {
                if (e.delta.dx > 0) {
                  value = 1;
                } else if (e.delta.dx < 0) {
                  value = 0;
                }
              });
            },
          )
        ],
      ),
    );
  }
}
