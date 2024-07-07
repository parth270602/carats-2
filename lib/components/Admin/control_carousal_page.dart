import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ControlCarousalPage extends StatefulWidget {
  const ControlCarousalPage({Key? key}) : super(key: key);

  @override
  _ControlCarousalPageState createState() => _ControlCarousalPageState();
}

class _ControlCarousalPageState extends State<ControlCarousalPage> {
  final TextEditingController _imageUrlController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _addImage() {
    String imageUrl = _imageUrlController.text.trim();
    if (imageUrl.isNotEmpty) {
      _firestore.collection('carousel').add({
        'imageUrl': imageUrl,
        // Add additional fields if needed, such as timestamp, etc.
      }).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image added successfully')),
        );
        _imageUrlController.clear();
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add image: $error')),
        );
      });
    }
  }

  void _deleteImage(String docId) {
    _firestore.collection('carousel').doc(docId).delete().then((value) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image deleted successfully')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete image: $error')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Control Carousel'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _imageUrlController,
              decoration: const InputDecoration(labelText: 'Image URL'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _addImage,
              child: const Text('Add Image'),
            ),
            const SizedBox(height: 32.0),
            const Text(
              'Current Images:',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('carousel').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text('No images available');
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: snapshot.data!.docs.map((doc) {
                    String imageUrl = doc['imageUrl'] as String;
                    String docId = doc.id;
                    return ListTile(
                      title: Text(imageUrl),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteImage(docId),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
