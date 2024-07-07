import 'package:flutter/material.dart';

class BillDetailsPage extends StatelessWidget {
  final String imageUrl;
  final String uploadedAt;
  final String comments;
  final bool status;
  final String adminComments;

  
  const BillDetailsPage({
    required this.imageUrl,
    required this.uploadedAt,
    required this.comments,
    required this.status,
    required this.adminComments,
    super.key,
    });


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bill Details"),
      ),
      body:SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Image.network(imageUrl,fit:BoxFit.contain),
            const SizedBox(height: 16),
            Text('UploadedAt: $uploadedAt',style:const TextStyle(fontSize: 18)),

            const SizedBox(height: 16),
            Text('Your comments: $comments',style:const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            Text('Bill Status: $status',style:const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            Text('Admin Comments: $adminComments',style:const TextStyle(fontSize: 18)),
          ],))
    );
  }
}