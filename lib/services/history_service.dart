import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<Map<String, dynamic>>> getTransactionHistory() async {
    String userId = _auth.currentUser!.uid;

    // Fetch ledger transactions
    QuerySnapshot ledgerSnapshot = await _firestore
        .collection('users/$userId/ledger')
        .orderBy('date', descending: true)
        .get();

    // Combine ledger data with coupon status
    List<Map<String, dynamic>> transactions = await Future.wait(
      ledgerSnapshot.docs.map((ledgerDoc) async {
        Map<String, dynamic> ledgerData = ledgerDoc.data() as Map<String, dynamic>;

        if (ledgerData['type'] == 'coupon') {
          // Extract coupon code from description
          RegExp regex = RegExp(r'\(Code: (\w+)\)');
          Match? match = regex.firstMatch(ledgerData['description']);
          String? couponCode = match?.group(1);

          if (couponCode != null) {
            // Fetch coupon status
            DocumentSnapshot couponDoc = await _firestore
                .collection('users/$userId/coupons')
                .doc(couponCode)
                .get();

            ledgerData['status'] = couponDoc.exists ? (couponDoc.data() as Map<String, dynamic>)['status'] : 'unknown';
          }
        }

        return ledgerData;
      }).toList(),
    );

    return transactions;
  }
}
