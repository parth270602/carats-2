import 'package:flutter/material.dart';
import 'package:restaurantapp/components/Admin/control_carousal_page.dart';

class AdminPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ControlCarousalPage()),);
          },
          child: Text('Manage Carousel'),
          ),
      ),
    );
  }
}
