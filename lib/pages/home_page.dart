import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:restaurantapp/components/Admin/admin_page.dart';
import 'package:restaurantapp/components/User/user_page.dart';
import 'package:restaurantapp/pages/login_page.dart';
import 'package:restaurantapp/services/reward_service.dart';
import 'package:restaurantapp/services/user_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RewardService _rewardService = RewardService();
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _rewardService.giveDailyReward();
  }

  Future<String?> _getUserRoll() async {
    User? user = _auth.currentUser;
    if (user == null) {
      return null;
    }

    await _userService.checkAndCreateWallet(user);

    DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

    if (data != null && data.containsKey('roll')) {
      return data['roll'];
    } else {
      return null;
    }
  }

  void _logout(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: FutureBuilder<String?>(
        future: _getUserRoll(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            String? roll = snapshot.data;
            if (roll == 'admin') {
              return AdminPage();
            } else if (roll == 'user') {
              return  UserPage();
            } else {
              return const Center(child: Text('Role not found'));
            }
          }
        },
      
      ),      
       
     );
  }
}
