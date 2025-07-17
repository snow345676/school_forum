import 'dart:convert';
import 'package:flutter/material.dart';

class Custom3DAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onMenuPressed;
  final VoidCallback onProfilePressed;
  final String? avatarBase64;

  const Custom3DAppBar({
    super.key,
    required this.onMenuPressed,
    required this.onProfilePressed,
    this.avatarBase64,
  });

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    final Color mainColor = const Color(0xFF0C6F8B);
    final Color lighterColor = const Color(0xFF3AA0C9);
    final Color shadowColor = const Color(0xFF084A59);

    ImageProvider avatarImage;
    if (avatarBase64 != null && avatarBase64!.isNotEmpty) {
      try {
        avatarImage = MemoryImage(base64Decode(avatarBase64!));
      } catch (_) {
        avatarImage = const AssetImage('assets/default_avatar.png');
      }
    } else {
      avatarImage = const AssetImage('assets/default_avatar.png');
    }

    return Material(
      elevation: 5,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [mainColor, lighterColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: shadowColor.withOpacity(0.6),
              offset: const Offset(0, 3),
              blurRadius: 2,
              spreadRadius: 0,
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white, size: 30),
                  onPressed: onMenuPressed,
                  tooltip: 'Menu',
                ),
                Text(
                  'School Net',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 23,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: onProfilePressed,
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    backgroundImage: avatarImage,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
