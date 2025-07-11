import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class HomeBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChange;

  const HomeBottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onTabChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mainColor = const Color(0xFF0C6F8B);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 12),
      child: GNav(
        selectedIndex: selectedIndex,
        onTabChange: onTabChange,
        gap: 8,
        tabBorderRadius: 16,
        backgroundColor: Colors.white,
        color: Colors.black54,
        activeColor: mainColor,
        tabBackgroundColor: mainColor.withOpacity(0.15),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        tabs: const [
          GButton(icon: Icons.home, text: 'Home'),
          GButton(icon: Icons.add_box, text: 'Add Post'),
          GButton(icon: Icons.chat_bubble, text: 'Chat'),
          GButton(icon: Icons.favorite_border, text: 'Friends'),
        ],
      ),
    );
  }
}