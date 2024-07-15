import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:restaurantapp/services/reward_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RewardsPage extends StatefulWidget {
  const RewardsPage({super.key});

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RewardService _rewardService = RewardService();
  final ConfettiController _confettiController = ConfettiController(duration: const Duration(seconds: 2));

  bool _rewardCollected = false;

  @override
  void initState() {
    super.initState();
    _checkRewardStatus();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _checkRewardStatus() async {
    final prefs = await SharedPreferences.getInstance();
    String userId = _auth.currentUser?.uid ?? '';
    DateTime now = DateTime.now();
    String lastRewardDate = prefs.getString('lastRewardDate_$userId') ?? '';

    setState(() {
      _rewardCollected = lastRewardDate == now.toIso8601String().split('T')[0];
    });
  }

  Future<Map<String, dynamic>?> _getUserRewards() async {
    User? user = _auth.currentUser;
    if (user == null) return null;

    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      print('Error fetching user rewards: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> _getRewardSettings() async {
    try {
      DocumentSnapshot doc = await _firestore.collection('settings').doc('rewards').get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      print('Error fetching reward settings: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder<Map<String, dynamic>?>(
            future: Future.wait([_getUserRewards(), _getRewardSettings()]).then((values) {
              return {
                'user': values[0],
                'settings': values[1],
              };
            }),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                return _buildRewardsUI(snapshot.data);
              }
            },
          ),
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
            ),
          )
        ],
      ),
      
    );
  }

  Widget _buildRewardsUI(Map<String, dynamic>? data) {
    if (data == null) {
      return const Center(child: Text("Data not found"));
    }

    Map<String, dynamic>? userData = data['user'];
    Map<String, dynamic>? settingsData = data['settings'];

    if (userData == null || settingsData == null) {
      return const Center(child: Text("User Data or Settings Data not found"));
    }

    int balance = userData['wallet']['balance'] ?? 0;
    int minReward = settingsData['minReward'];
    int maxReward = settingsData['maxReward'];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Rewards Balance: $balance coins',
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _rewardCollected ? null : () {
            _redeemDailyRewards();
          },
          child: const Text('Get Today\'s Rewards'),
        ),
      ],
    );
    
  }

  void _redeemDailyRewards() {
    User? user = _auth.currentUser;
    if (user == null) return;

    _rewardService.giveDailyReward().then((_) {
      setState(() {
        _rewardCollected = true;
        _confettiController.play();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Daily rewards redeemed successfully!')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to redeem daily rewards: $error')),
      );
    });
  }
}
