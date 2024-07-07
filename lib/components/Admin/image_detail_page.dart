import 'package:flutter/material.dart';

class ImageDetailPage extends StatelessWidget {
  final String imageUrl;
  final String uploaderEmail;
  final String uploadedAt;
  final String comments;

  const ImageDetailPage({
    required this.imageUrl,
    required this.uploaderEmail,
    required this.uploadedAt,
    required this.comments,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image Details"),
      ),
      body:SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Image.network(imageUrl,fit: BoxFit.contain),
            const SizedBox(height: 16),
            Text("Uploaded By: $uploaderEmail",style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text("Uploaded At:$uploadedAt", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text("User Comments: $comments" ,style:const TextStyle(fontSize: 18))
          ],
        ),
        ),
    );
  }
}