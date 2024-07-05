import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RewardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> giveDailyReward() async {
    final prefs = await SharedPreferences.getInstance();
    String userId = _auth.currentUser!.uid;
    DateTime now = DateTime.now();
    String lastRewardDate = prefs.getString('lastRewardDate_$userId') ?? '';

    try {
      if (lastRewardDate != now.toIso8601String().split('T')[0]) {
        int dailyCoins = Random().nextInt(21) + 10;
        DocumentReference userDoc = _firestore.collection('users').doc(userId);

        DocumentSnapshot snapshot = await userDoc.get();
        if (!snapshot.exists) {
          throw Exception("User Doesn't exist");
        }

        // Accessing wallet balance safely using type checks and casts
        dynamic userData = snapshot.data();
        if (userData != null && userData['wallet'] != null) {
          Map<String, dynamic> walletData = userData['wallet'];
          int currentBalance = walletData['balance'] ?? 0;

          int newBalance = currentBalance + dailyCoins;

          // Prepare update data
          Map<String, dynamic> updateData = {
            'wallet.balance': newBalance,
          };

          // Add rewards history using server timestamp in a map
          updateData['wallet.rewardsHistory'] = FieldValue.arrayUnion([
            {
              'coins': dailyCoins,
              'date': Timestamp.now(), // Use Timestamp.now() instead of FieldValue.serverTimestamp()
              'type': 'daily'
            }
          ]);

          await userDoc.update(updateData);

          prefs.setString('lastRewardDate_$userId', now.toIso8601String().split('T')[0]);
        } else {
          throw Exception("User data or wallet data not found");
        }
      } else {
        print('User already received daily rewards today.');
      }
    } catch (e) {
      print('Error giving daily reward: $e');
      throw e; // Rethrow the exception to handle it further up the call stack if neede
      //asdadadass
    }
  }
}
