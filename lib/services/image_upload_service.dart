import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class ImageUploadService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  Future<void> pickAndUploadImage(BuildContext context) async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

      File? croppedFile = await _cropImage(pickedFile.path);
      if (croppedFile == null) return;

      String? downloadUrl = await _uploadImage(croppedFile);
      if (downloadUrl != null) {
        await _saveImageUrlToFirestore(downloadUrl);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image uploaded successfully!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
    }
  }

  Future<File?> _cropImage(String imagePath) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imagePath,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.blue,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          minimumAspectRatio: 1.0,
        ),
      ],
    );

    return croppedFile != null ? File(croppedFile.path) : null;
  }

  Future<String?> _uploadImage(File file) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return null;

      String filePath = 'bill_images/${user.email}/${DateTime.now().microsecondsSinceEpoch}.png';
      UploadTask uploadTask = _storage.ref().child(filePath).putFile(file);

      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Failed to upload image: $e');
      return null;
    }
  }

  Future<void> _saveImageUrlToFirestore(String downloadUrl) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('images').add({
      'url': downloadUrl,
      'approved': false,
      'userId': user.uid,
      'email':user.email,
      'uploadedAt': FieldValue.serverTimestamp(),
    });
  }
}