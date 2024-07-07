import 'package:flutter/material.dart';
import 'package:restaurantapp/components/User/bill_history_page.dart';
import 'package:restaurantapp/components/User/carousal_page.dart';
import 'package:restaurantapp/components/User/history_page.dart';
import 'package:restaurantapp/components/User/rewards_page.dart';
import 'package:restaurantapp/components/User/upload_bill_page.dart';
import 'package:restaurantapp/pages/redeem_page.dart';


class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const CarousalPage(),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed:() {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context)=> const RewardsPage()),
                );
            } , 
            child: const Text('View Rewards')
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => const RedeemPage()),
                  );
              }, 
              child: const Text("Redeem Coupon")
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HistoryPage()),
                    );
                }, 
                child: const Text("Transaction History")),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => const UploadBillPage()),
                    );
                },
               child: const Text('Upload Bill')
               ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => const BillPage()),
                    );
                },
               child: const Text('Bills History')
               )
        ],
      ),
    );
  }
}
