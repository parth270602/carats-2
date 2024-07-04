import 'package:flutter/material.dart';
import 'package:restaurantapp/services/image_upload_service.dart';

class UploadBillPage extends StatefulWidget {
  const UploadBillPage({super.key});

  @override
  State<UploadBillPage> createState() => _UploadBillPageState();
}

class _UploadBillPageState extends State<UploadBillPage> {
  final ImageUploadService _imageUploadService = ImageUploadService();
  bool _isUploading = false;

  Future<void> _pickAndUploadImage() async {
    setState(() {
      _isUploading = true;
    });

    await _imageUploadService.pickAndUploadImage(context);

    setState(() {
      _isUploading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Bill Image'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _isUploading ? null : _pickAndUploadImage,
              child: _isUploading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Pick and Upload Image'),
            ),
          ],
        ),
      ),
    );
  }
}
