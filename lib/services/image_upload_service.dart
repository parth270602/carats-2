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
  String? _uploadedImageUrl;
  File? _selectedImage;

  File? get selectedImage => _selectedImage;

  Future<void> pickImage(BuildContext context, ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile == null) return;

      _selectedImage = await _cropImage(pickedFile.path);
      if (_selectedImage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image loaded successfully!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load image: $e')),
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

  Future<void> submitReview(String review) async {
    if (_selectedImage == null) return;

    _uploadedImageUrl = await _uploadImage(_selectedImage!);
    if (_uploadedImageUrl == null) return;

    User? user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('images').add({
      'url': _uploadedImageUrl,
      'approved': false,
      'userId': user.uid,
      'email': user.email,
      'review': review,
      'rejectionReason': 'Bill Approved',
      'uploadedAt': FieldValue.serverTimestamp(),
    });

    _selectedImage = null; // Clear the selected image after upload
  }
}
