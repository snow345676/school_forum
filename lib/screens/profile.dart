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

  //Load saved profile image from Firestore
  Future<void> loadProfileImage() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final snapshot = await FirebaseFirestore.instance.collection('users').where('uid', isEqualTo: uid).get();
    if (snapshot.docs.isNotEmpty) {
      setState(() {
        imageUrl = snapshot.docs.first['profileImage'] ?? '';
      });
    }
  }

  //Pick, crop, and upload
  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        cropStyle: CropStyle.circle,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
        ],
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Profile Image',
            toolbarColor: Colors.cyan,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: true,
          ),
        ],
      );

      if (croppedFile != null) {
        await uploadToFirebase(File(croppedFile.path));
      }
    }
  }

  // ☁️ Upload to Firebase Storage
  Future<void> uploadToFirebase(File file) async {
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
  }

  @override
  Widget build(BuildContext context) {
    return Center(
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
    );
  }
}
