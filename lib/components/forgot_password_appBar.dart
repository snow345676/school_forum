import 'package:flutter/material.dart';

class ForgotPasswordAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onBack;

  const ForgotPasswordAppBar({
    super.key,
    required this.onBack,
  });

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    final Color mainColor = const Color(0xFF0C6F8B);
    final Color lighterColor = const Color(0xFF3AA0C9);
    final Color shadowColor = const Color(0xFF084A59);

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
              spreadRadius: 1,
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                  onPressed: onBack,
                  tooltip: 'Back',
                ),
                const SizedBox(width: 10),
                const Text(
                  'Forgot Password',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
