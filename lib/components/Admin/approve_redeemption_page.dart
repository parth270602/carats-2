import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:restaurantapp/services/admin_service.dart';
import 'package:restaurantapp/services/reject_redeem_service.dart';

class ApproveRedemptionsPage extends StatefulWidget {
  const ApproveRedemptionsPage({super.key});

  @override
  State<ApproveRedemptionsPage> createState() => _ApproveRedemptionsPageState();
}

class _ApproveRedemptionsPageState extends State<ApproveRedemptionsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AdminService _adminService = AdminService();
  final RejectRedeemService _rejectRedeemService = RejectRedeemService();

  Future<List<Map<String, dynamic>>> _fetchPendingRedemptions() async {
    QuerySnapshot snapshot = await _firestore.collectionGroup('redeemRequests')
      .where('status', isEqualTo: 'pending')
      .orderBy('date')
      .get();
    return snapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['userId'] = doc.reference.parent.parent!.id;
      data['requestId'] = doc.id;
      return data;
    }).toList();
  }

  void _approveRedemption(String userId, String requestId, int amount) async {
    try {
      await _adminService.approveRedemption(userId, requestId);
      setState(() {}); // Refresh the list after approval
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Redemption approved successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to approve redemption: $e')),
      );
    }
  }

  void _rejectRedemption(String userId, String requestId) async {
    TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reject Redemption'),
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
                  await _rejectRedeemService.rejectRedeem(requestId, userId, reasonController.text);
                  Navigator.pop(context);
                  setState(() {}); // Refresh the list after rejection
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Redemption rejected successfully!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to reject redemption: $e')),
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
      appBar: AppBar(
        title: const Text('Approve Redemptions'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchPendingRedemptions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<Map<String, dynamic>> pendingRedemptions = snapshot.data!;
            return ListView.builder(
              itemCount: pendingRedemptions.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> redemption = pendingRedemptions[index];
                return ListTile(
                  title: Text('Redeem ${redemption['amount']} coins'),
                  subtitle: Text('User ID: ${redemption['userId']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _approveRedemption(redemption['userId'], redemption['requestId'], redemption['amount']);
                        },
                        child: const Text('Approve'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          _rejectRedemption(redemption['userId'], redemption['requestId']);
                        },
                        child: const Text('Reject'),
                       
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
