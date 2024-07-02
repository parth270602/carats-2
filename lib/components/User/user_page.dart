import 'package:flutter/material.dart';
import 'package:restaurantapp/components/User/carousal_page.dart';
import 'package:restaurantapp/components/User/rewards_page.dart';

class UserPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CarousalPage(),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed:() {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context)=> RewardsPage()),
                );
            } , 
            child: Text('View Rewards'))
        ],
      ),
    );
  }
}
