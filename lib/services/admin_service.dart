import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'redeem_service.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RedeemService _redeemService = RedeemService();

  Future<void> approveRedemption(String userId, String requestId) async {
    await _redeemService.approveRedeem(requestId, userId);
  }
}
