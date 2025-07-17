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

  // Controllers for editable fields
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController rollNumberController = TextEditingController();

  bool isLoading = true;
  String? error;
  String? avatarBase64;

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
        addressController.text = data['address'] ?? '';
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
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .update({
          'username': usernameController.text,
          'email': emailController.text,
          'phone': phoneController.text,
          'address': addressController.text,
          'year': yearController.text,
          'rollNumber': rollNumberController.text,
          'avatar_base64': avatarBase64 ?? '',
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
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
        title: const Text("Settings"),
        backgroundColor: const Color(0xFF0C6F8B),
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
                      ? const Icon(Icons.person, size: 60)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              buildTextField("Username", usernameController),
              buildTextField("Email", emailController),
              buildTextField("Phone", phoneController),
              buildTextField("Address", addressController),
              buildTextField("Academic Year", yearController),
              buildTextField("Roll Number", rollNumberController),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: updateUserData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0C6F8B),
                ),
                child: const Text("Save Changes"),
              )
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
        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
      ),
    );
  }
}
