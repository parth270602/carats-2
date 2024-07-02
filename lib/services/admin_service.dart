import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> approveCoupon(String userId, String couponCode) async {
    DocumentReference userDoc = _firestore.collection('users').doc(userId);
    DocumentReference couponDoc = userDoc.collection('coupons').doc(couponCode);

    DocumentSnapshot couponSnapshot = await couponDoc.get();
    if (!couponSnapshot.exists) {
      throw Exception('Coupon Doesnt Exist');
    }

    await couponDoc.update({'status': 'approved'});
  }
}
