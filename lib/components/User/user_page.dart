import 'package:flutter/material.dart';
import 'package:restaurantapp/components/User/carousal_page.dart';

class UserPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Dashboard'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CarousalPage()),
            );
          },
          child: Text('View Carousel'),
        ),
      ),
    );
  }
}
