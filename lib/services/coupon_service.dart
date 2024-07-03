import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CouponService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _generateCouponCode() {
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random random = Random();
    return String.fromCharCodes(Iterable.generate(
      7,
      (_) => characters.codeUnitAt(random.nextInt(characters.length)),
    ));
  }

  Future<void> createCoupon(String couponType, int coinCost) async {
    String userId = _auth.currentUser!.uid;
    DocumentReference userDoc = _firestore.collection('users').doc(userId);

    DocumentSnapshot snapshot = await userDoc.get();
    if (!snapshot.exists) {
      throw Exception("User doesn't exist");
    }

    dynamic userData = snapshot.data();
    if (userData != null) {
      int currentBalance = userData['wallet']['balance'] ?? 0;

      if (currentBalance < coinCost) {
        throw Exception("Not enough coins");
      }

      int newBalance = currentBalance - coinCost;
      String couponCode = _generateCouponCode();
      print(newBalance);

      await _firestore.runTransaction((transaction) async {
        // Update user's balance
        transaction.update(userDoc, {
          'wallet.balance': newBalance,
        });

        // Add ledger entry
        transaction.set(_firestore.collection('users/$userId/ledger').doc(), {
          'amount': coinCost,
          'date': Timestamp.now(),
          'type': 'coupon',
          'description': '$couponType coupon purchased (Code: $couponCode)',
        });

        // Add coupon
        transaction.set(_firestore.collection('users/$userId/coupons').doc(couponCode), {
          'code': couponCode,
          'type': couponType,
          'status': 'pending',
          'date': Timestamp.now(),
        });
      });
    } else {
      throw Exception("User data not found");
    }
  }
}
