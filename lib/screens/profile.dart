import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePictureWidget extends StatefulWidget {
  @override
  _ProfilePictureWidgetState createState() => _ProfilePictureWidgetState();
}

class _ProfilePictureWidgetState extends State<ProfilePictureWidget> {
  String imageUrl = '';
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    loadProfileImage();
  }

  // Load saved profile image from Firestore
  Future<void> loadProfileImage() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('uid', isEqualTo: uid)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        if (data.containsKey('profileImage')) {
          setState(() {
            imageUrl = data['profileImage'];
          });
        }
      }
    } catch (e) {
      print("Error loading profile image: $e");
    }
  }

  // Pick and crop image
  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No image selected")),
      );
      return;
    }

    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Profile Image',
          toolbarColor: Colors.cyan,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Crop Profile Image',
          aspectRatioLockEnabled: true,
        ),
      ],
    );

    if (croppedFile != null) {
      await uploadToFirebase(File(croppedFile.path));
    }
  }

  // Upload to Firebase Storage
  Future<void> uploadToFirebase(File file) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final ref = FirebaseStorage.instance.ref().child('profile_images/$uid.jpg');

      await ref.putFile(file);
      String downloadURL = await ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'profileImage': downloadURL,
      });

      setState(() {
        imageUrl = downloadURL;
      });
    } catch (e) {
      print("Upload error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload failed: $e")),
      );
    } finally {
      Navigator.pop(context); // remove loading dialog
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.cyan,
        
      ),
      body: Center(
        child: Stack(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: imageUrl.isNotEmpty
                  ? NetworkImage(imageUrl)
                  : NetworkImage('https://cdn-icons-png.flaticon.com/512/149/149071.png'),
            ),
            Positioned(
              bottom: 0,
              right: 4,
              child: GestureDetector(
                onTap: pickImage,
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.cyan,
                  child: Icon(Icons.add, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
