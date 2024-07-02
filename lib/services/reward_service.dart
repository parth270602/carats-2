import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RewardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> giveDailyReward() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    try {
      // Fetch min and max reward values
      DocumentSnapshot settingsDoc = await _firestore.collection('settings').doc('rewards').get();
      int minReward = int.parse(settingsDoc['minReward'].toString());
      int maxReward = int.parse(settingsDoc['maxReward'].toString());

      // Generate a random reward between min and max values
      Random random = Random();
      int reward = minReward + random.nextInt(maxReward - minReward + 1);

      // Update user's wallet balance and lastRewarded timestamp
      DocumentReference userDoc = _firestore.collection('users').doc(user.uid);
      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(userDoc);
        if (!snapshot.exists) {
          throw Exception("User does not exist!");
        }

        int currentBalance = snapshot['wallet']['balance'];
        Timestamp? lastRewarded = snapshot['lastRewarded'];
        DateTime now = DateTime.now();

        // Check if the user has already received the reward today
        if (lastRewarded != null) {
          DateTime lastRewardedDate = lastRewarded.toDate();
          if (lastRewardedDate.year == now.year &&
              lastRewardedDate.month == now.month &&
              lastRewardedDate.day == now.day) {
            throw Exception("Daily reward already redeemed today");
          }
        }

        transaction.update(userDoc, {
          'wallet.balance': currentBalance + reward,
          'lastRewarded': now,
        });
      });
    } catch (e) {
      print('Error giving daily reward: $e');
      throw e;
    }
  }
}
