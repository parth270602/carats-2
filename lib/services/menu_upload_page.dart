import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class MenuUploader {
  // Convert image file to base64
  Future<String> imageFileToBase64(File imageFile) async {
    Uint8List bytes = await imageFile.readAsBytes();
    String base64Image = base64Encode(bytes);
    return base64Image;
  }

  // Upload base64 image to Firestore
  Future<void> uploadBase64ImageToMenu(String base64Image) async {
    CollectionReference menu = FirebaseFirestore.instance.collection('menu');
    await menu.add({
      'base64Image': base64Image,
    });
  }

  // Upload single image
  Future<void> uploadImage(File imageFile) async {
    String base64Image = await imageFileToBase64(imageFile);
    await uploadBase64ImageToMenu(base64Image);
  }

  // Upload multiple images
  Future<void> uploadImages(List<File> imageFiles) async {
    for (File imageFile in imageFiles) {
      await uploadImage(imageFile);
    }
  }
}
