import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RejectRedeemService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> rejectRedeem(String requestId, String userId, String reason) async {
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

      // Update Redeem request status with reason
      await _firestore
          .collection('users/$userId/redeemRequests')
          .doc(requestId)
          .update({
        'status': 'rejected',
        'reason': reason, // Add rejection reason
      });

      // Begin Firestore transaction
      await _firestore.runTransaction((transaction) async {
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

          // Ledger entry for admin (adding coins)
          DocumentReference adminLedgerDocAdd = _firestore.collection('users/${admin.id}/ledger').doc();
          transaction.set(adminLedgerDocAdd, {
            'amount': coinAmount,
            'date': Timestamp.now(),
            'type': 'redeem',
            'description': 'Coins temporarily added for rejected redemption from ${userData['email']}',
          });

          // Subtract coins from admin's balance
          newAdminBalance = newAdminBalance - coinAmount;
          transaction.update(adminDoc, {
            'wallet.balance': newAdminBalance,
          });

          // Ledger entry for admin (subtracting coins)
          DocumentReference adminLedgerDocSubtract = _firestore.collection('users/${admin.id}/ledger').doc();
          transaction.set(adminLedgerDocSubtract, {
            'amount': -coinAmount,
            'date': Timestamp.now(),
            'type': 'redeem',
            'description': 'Coins removed after rejection of redemption from ${userData['email']}',
          });
        }

        // Update user balance
        int userBalance = userData['wallet']['balance'] ?? 0;
        int newUserBalance = userBalance + coinAmount;
        transaction.update(userDoc, {
          'wallet.balance': newUserBalance,
        });

        // Ledger entry for user
        DocumentReference userLedgerDoc = _firestore.collection('users/$userId/ledger').doc();
        transaction.set(userLedgerDoc, {
          'amount': coinAmount,
          'date': Timestamp.now(),
          'type': 'redeem',
          'description': 'Coins refunded due to rejection of redemption request',
        });
      });
    } else {
      throw Exception("User not found");
    }
  }
}
