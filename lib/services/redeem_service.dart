import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RedeemService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> requestRedeem(int coinAmount) async {
    String userId = _auth.currentUser!.uid;
    DocumentReference userDoc = _firestore.collection('users').doc(userId);

    DocumentSnapshot snapshot = await userDoc.get();
    if (!snapshot.exists) {
      throw Exception("User doesn't exist");
    }

    dynamic userData = snapshot.data();
    if (userData != null) {
      int currentBalance = userData['wallet']['balance'] ?? 0;

      if (currentBalance < coinAmount) {
        throw Exception("Not enough coins");
      }

      // Deduct the coin amount from the user's balance immediately
      int newBalance = currentBalance - coinAmount;
      await userDoc.update({
        'wallet.balance': newBalance,
      });

      // Add redeem request entry
      await _firestore.collection('users/$userId/redeemRequests').add({
        'amount': coinAmount,
        'date': Timestamp.now(),
        'status': 'pending',
        'userId': userId,
      });

      // Ledger entry for user
      await _firestore.collection('users/$userId/ledger').add({
        'amount': coinAmount,

        'date': Timestamp.now(),
        'type': 'redeem',
        'description': 'Coin redeem requested',
        'userId':userId
      });
    } else {
      throw Exception("User data not found");
    }
  }

  Future<void> approveRedeem(String requestId, String userId) async {
    DocumentReference userDoc = _firestore.collection('users').doc(userId);

    DocumentSnapshot snapshot = await userDoc.get();
    if (!snapshot.exists) {
      throw Exception('User doesn\'t exist');
    }

    dynamic userData = snapshot.data();
    if (userData != null) {
      int coinAmount = (await _firestore
              .collection('users/$userId/redeemRequests')
              .doc(requestId)
              .get())
          .data()?['amount'] ?? 0;

      // Start a transaction to ensure atomicity
      await _firestore.runTransaction((transaction) async {
        // Update Redeem request status
        DocumentReference redeemRequestDoc = _firestore
            .collection('users/$userId/redeemRequests')
            .doc(requestId);
        transaction.update(redeemRequestDoc, {
          'status': 'approved',
        });

        // Fetch admin details
        QuerySnapshot adminSnapshot = await _firestore
            .collection('users')
            .where('roll', isEqualTo: 'admin')
            .get();

        for (var admin in adminSnapshot.docs) {
          int adminBalance = admin['wallet']['balance'] ?? 0;
          int newAdminBalance = adminBalance + coinAmount;

          // Update admin balance
          DocumentReference adminDoc = _firestore.collection('users').doc(admin.id);
          transaction.update(adminDoc, {
            'wallet.balance': newAdminBalance,
          });

          // Ledger entry for admin
          DocumentReference adminLedgerDoc = _firestore.collection('users/${admin.id}/ledger').doc();
          transaction.set(adminLedgerDoc, {
            'amount': coinAmount,
            'date': Timestamp.now(),
            'type': 'redeem',
            'description': 'Coins received from ${userData['email']}',
          });
        }
      });
    } else {
      throw Exception("User not found");
    }
  }
}
