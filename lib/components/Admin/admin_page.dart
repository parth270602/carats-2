import 'package:flutter/material.dart';
import 'package:restaurantapp/components/Admin/approve_redeemption_page.dart';
import 'package:restaurantapp/components/Admin/control_carousal_page.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ControlCarousalPage()),
                );
              },
              child: const Text('Manage Carousel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => const ApproveRedemptionsPage()),
                  );
              }, child: const Text('Approve Coupons'))
          ],
        ),
      ),
    );
  }
}
