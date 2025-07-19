import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final currentUser = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController rollNumberController = TextEditingController();

  bool isLoading = true;
  String? error;
  String? avatarBase64;

  final Color mainColor = const Color(0xFF0C6F8B);
  final Color shadowColor = const Color(0xFF084A59);

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        usernameController.text = data['username'] ?? '';
        emailController.text = data['email'] ?? '';
        phoneController.text = data['phone'] ?? '';
        yearController.text = data['year'] ?? '';
        rollNumberController.text = data['rollNumber'] ?? '';
        avatarBase64 = data['avatar_base64'] ?? '';
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = "Failed to load user data: $e";
        isLoading = false;
      });
    }
  }

  Future<void> updateUserData() async {
    if (_formKey.currentState!.validate()) {
      try {
        final newUsername = usernameController.text.trim();

        // Update user document
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .update({
          'username': newUsername,
          'email': emailController.text.trim(),
          'phone': phoneController.text.trim(),
          'year': yearController.text.trim(),
          'rollNumber': rollNumberController.text.trim(),
          'avatar_base64': avatarBase64 ?? '',
        });


        final postsSnapshot = await FirebaseFirestore.instance
            .collection('User_Posts')
            .where('uid', isEqualTo: currentUser!.uid)
            .get();

        for (final doc in postsSnapshot.docs) {
          await doc.reference.update({'UserEmail': newUsername});
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile & posts updated successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: $e')),
        );
      }
    }
  }

  Future<void> _pickNewAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        avatarBase64 = base64Encode(bytes);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image selected!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? avatarImage;
    if (avatarBase64 != null && avatarBase64!.isNotEmpty) {
      try {
        avatarImage = MemoryImage(base64Decode(avatarBase64!));
      } catch (_) {
        avatarImage = null;
      }
    }

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Settings",style: TextStyle(color: Colors.white),),
        backgroundColor: mainColor,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text(error!))
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: _pickNewAvatar,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: avatarImage,
                  child: avatarImage == null
                      ? Icon(Icons.person, size: 100, color: shadowColor)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              buildTextField("Username", usernameController),
              buildTextField("Email", emailController),
              buildTextField("Phone", phoneController),
              buildTextField("Academic Year", yearController),
              buildTextField("Roll Number", rollNumberController),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: updateUserData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  "Save Changes",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) =>
        value == null || value.trim().isEmpty ? 'Required' : null,
      ),
    );
  }
}
