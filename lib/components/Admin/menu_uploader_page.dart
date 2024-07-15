import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:restaurantapp/services/menu_upload_page.dart';


class MenuUploaderPage extends StatefulWidget {
  const MenuUploaderPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MenuUploaderPageState createState() => _MenuUploaderPageState();
}

class _MenuUploaderPageState extends State<MenuUploaderPage> {
  final MenuUploader imageUploader = MenuUploader();
  final ImagePicker picker = ImagePicker();
  bool isLoading = false;

  // Method to select and upload images
  Future<void> uploadImages() async {
    setState(() {
      isLoading = true;
    });

    List<XFile>? images = await picker.pickMultiImage();

    if (images.isNotEmpty) {
      // Convert XFile to File
      List<File> imageFiles = images.map((image) => File(image.path)).toList();
      await imageUploader.uploadImages(imageFiles);

      setState(() {
        isLoading = false;
      });

      showAlertDialog(context, 'Upload Complete', 'Images have been successfully uploaded.');
    } else {
      setState(() {
        isLoading = false;
      });

      showAlertDialog(context, 'No Images Selected', 'Please select images to upload.');
    }
  }

  // Method to show alert dialog
  void showAlertDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menu Uploader'),
      ),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : ElevatedButton(
                onPressed: uploadImages,
                child: Text('Upload Images as Base64'),
              ),
      ),
    );
  }
}
