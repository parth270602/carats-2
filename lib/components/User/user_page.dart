import 'package:flutter/material.dart';
import 'package:restaurantapp/components/User/carousal_page.dart';

class UserPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CarousalPage(), // Call the reusable carousel widget here
          // Add other content for UserPage here
        ],
      ),
    );
  }
}
