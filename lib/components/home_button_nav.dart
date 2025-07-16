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
    final Color mainColor = Colors.grey.shade100;
    final Color middeleColor = Colors.grey.shade200;
    final Color lighterColor = Colors.grey.shade300;

    final Color bmainColor = const Color(0xFF0C6F8B);
    final Color blighterColor = const Color(0xFF3AA0C9);
    final Color bshadowColor = const Color(0xFF084A59);


    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [mainColor,middeleColor, lighterColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),

      ),
      // color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
      gradient: LinearGradient(
      colors: [mainColor,middeleColor, lighterColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      )),
        child: GNav(
          selectedIndex: selectedIndex,
          onTabChange: onTabChange,
          gap: 8,
          tabBorderRadius: 16,

          color: Colors.black54,
          activeColor: bmainColor,
          tabBackgroundColor: bmainColor.withOpacity(0.15),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          tabs: [
            GButton(icon: Icons.home, text: 'Home',),
            GButton(icon: Icons.chat_bubble, text: 'Chat'),
            GButton(icon: Icons.add_box, text: 'Add Post'),
            GButton(icon: Icons.favorite_border, text: 'Friends'),
          ],
        ),
      ),
    );
  }
}