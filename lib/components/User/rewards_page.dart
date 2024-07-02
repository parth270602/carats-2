import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:restaurantapp/services/reward_service.dart';

class RewardsPage extends StatefulWidget {
  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RewardService _rewardService = RewardService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _getUserRewards(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return _buildRewardsUI(snapshot.data);
          }
        },
      ),
    );
  }

  Future<Map<String, dynamic>?> _getUserRewards() async {
    User? user = _auth.currentUser;
    if (user == null) return null;

    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(user.uid).get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      print('Error fetching user rewards: $e');
      return null;
    }
  }

  Widget _buildRewardsUI(Map<String, dynamic>? userData) {
    if (userData == null) {
      return Center(child: Text("User Data not found"));
    }

    int balance = userData['wallet']['balance'] ?? 0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Rewards Balance: $balance coins',
          style: TextStyle(fontSize: 24),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            _redeemDailyRewards();
          },
          child: Text('Redeem Today\'s Rewards'),
        ),
      ],
    );
  }

  void _redeemDailyRewards() {
    User? user = _auth.currentUser;
    if (user == null) return;

    _rewardService.giveDailyReward().then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Daily rewards redeemed successfully!')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to redeem daily rewards: $error')),
      );
    });
  }
}
