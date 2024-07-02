import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:restaurantapp/services/admin_service.dart';

class ApproveCouponsPage extends StatefulWidget {
  const ApproveCouponsPage({super.key});

  @override
  State<ApproveCouponsPage> createState() => _ApproveCouponsPageState();
}

class _ApproveCouponsPageState extends State<ApproveCouponsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AdminService _adminService = AdminService();

  Future<List<Map<String, dynamic>>> _fetchPendingCoupons() async {
    QuerySnapshot snapshot = await _firestore.collectionGroup('coupons')
      .where('status', isEqualTo: 'pending')
      .orderBy('date')
      .get();
    return snapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['userId'] = doc.reference.parent.parent!.id;
      return data;
    }).toList();
  }

  void _approveCoupon(String userId, String couponCode) async {
    try {
      await _adminService.approveCoupon(userId, couponCode);
      setState(() {}); // Refresh the list after approval
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coupon approved successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to approve coupon: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Approve Coupons'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchPendingCoupons(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<Map<String, dynamic>> pendingCoupons = snapshot.data!;
            return ListView.builder(
              itemCount: pendingCoupons.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> coupon = pendingCoupons[index];
                return ListTile(
                  title: Text('${coupon['type']} Coupon'),
                  subtitle: Text('Code: ${coupon['code']}'),
                  trailing: ElevatedButton(
                    onPressed: () {
                      _approveCoupon(coupon['userId'], coupon['code']);
                    },
                    child: const Text('Approve'),
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
