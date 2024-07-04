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

      // Update admin's wallet and ledger
      QuerySnapshot adminSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'admin')
          .get();
      for (var admin in adminSnapshot.docs) {
        int adminBalance = admin['wallet']['balance'] ?? 0;
        int newAdminBalance = adminBalance - coinAmount;
        await _firestore.collection('users').doc(admin.id).update({
          'wallet.balance': newAdminBalance,
        });

        // Ledger entry for admin
        await _firestore.collection('users/${admin.id}/ledger').add({
          'amount': coinAmount,
          'date': Timestamp.now(),
          'type': 'redeem',
          'description': 'Coins received from ${userData['email']}',
        });
      }
    } else {
      throw Exception("User not found");
    }
  }
}
