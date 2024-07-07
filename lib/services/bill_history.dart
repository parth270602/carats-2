import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BillHistory {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getBillHistory() async {
    User? user = _auth.currentUser;
    if (user == null) return [];

    List<Map<String, dynamic>> bills = [];

    try {
      QuerySnapshot billsSnapshot = await _firestore
          .collection('images')
          .where('userId', isEqualTo: user.uid)  
          .orderBy('uploadedAt', descending: true)  
          .get();

      bills = billsSnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; 
        return data;
      }).toList();
    } catch (e) {
      print(e);
    }
    return bills;
  }
}
