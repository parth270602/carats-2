import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getTransactionHistory() async {
    User? user = _auth.currentUser;
    if (user == null) return [];

    List<Map<String, dynamic>> transactions = [];

    try {
      QuerySnapshot ledgerSnapshot = await _firestore
          .collection('users/${user.uid}/ledger')
          .orderBy('date', descending: true)
          .get();

      for (var doc in ledgerSnapshot.docs) {
        var transaction = doc.data() as Map<String, dynamic>;

        if (transaction['type'] == 'redeem') {
          String? userId = transaction['userId'] as String?;
          if (userId != null) {
            DocumentSnapshot requestSnapshot = await _firestore
                .collection('users/${user.uid}/redeemRequests')
                .doc(userId)
                .get();
            if (requestSnapshot.exists) {
              transaction['status'] = requestSnapshot['status'] ?? 'Unknown';
              
            } else {
              transaction['status'] = 'Unknown';
            }
          } else {
            transaction['status'] = 'Unknown';
          }
        }
        transactions.add(transaction);
      }
    } catch (e) {
      print(e);
    }

    return transactions;
  }
}
