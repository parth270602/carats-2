import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:restaurantapp/components/Admin/image_detail_page.dart';

class AdminImageApprovalPage extends StatefulWidget {
  const AdminImageApprovalPage({super.key});

  @override
  State<AdminImageApprovalPage> createState() => _AdminImageApprovalPageState();
}

class _AdminImageApprovalPageState extends State<AdminImageApprovalPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot> _images = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('images').where('approved', isEqualTo: false).get();
      setState(() {
        _images = snapshot.docs;
        _isLoading = false;
      });
    } catch (e) {
      print('Failed to load images: $e');
    }
  }

  Future<void> _approveImage(String imageId, String userId) async {
    try {
      await _firestore.collection('images').doc(imageId).update({'approved': true});

      // Award coins to user
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      int currentCoins = userDoc['wallet']['balance'] ?? 0;
      await _firestore.collection('users').doc(userId).update({
        'wallet.balance': currentCoins + 10
      });

      // Remove approved image from the list
      setState(() {
        _images.removeWhere((image) => image.id == imageId);
      });
    } catch (e) {
      print('Failed to approve image: $e');
    }
  }

  Future<void> _rejectImage(String imageId, String reason) async {
    try {
      await _firestore.collection('images').doc(imageId).update({
        'approved': false,
        'rejectionReason': reason,
      });

      // Remove rejected image from the list
      setState(() {
        _images.removeWhere((image) => image.id == imageId);
      });
    } catch (e) {
      print('Failed to reject image: $e');
    }
  }

  void _showRejectionReasonDialog(String imageId) {
    TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reject Image'),
          content: TextField(
            controller: reasonController,
            decoration: const InputDecoration(
              hintText: 'Enter reason for rejection',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _rejectImage(imageId, reasonController.text);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Image rejected successfully!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to reject image: $e')),
                  );
                }
              },
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Approve Images')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _images.length,
              itemBuilder: (context, index) {
                var image = _images[index];
                Timestamp timestamp = image['uploadedAt'];
                DateTime dateTime = timestamp.toDate();
                String formattedDate = DateFormat('dd-MM-yyyy HH:mm:ss').format(dateTime);
                return ListTile(
                  leading: Image.network(image['url']),
                  title: Text('Uploaded By: ${image['email']}'),
                  subtitle: Text('Uploaded Date: $formattedDate'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImageDetailPage(
                          imageUrl: image['url'],
                          uploaderEmail: image['email'],
                          uploadedAt: formattedDate,
                        ),
                      ),
                    );
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check),
                        onPressed: () => _approveImage(image.id, image['userId']),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => _showRejectionReasonDialog(image.id),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
