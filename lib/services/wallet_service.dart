
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WalletService{
  final FirebaseFirestore _firestore=FirebaseFirestore.instance;
  final FirebaseAuth _auth=FirebaseAuth.instance;

  Future <void> redeemCoins(int coins) async{
    String userId=_auth.currentUser!.uid;
    DocumentReference userDoc=_firestore.collection('users').doc(userId);

    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot= await transaction.get(userDoc);
      if (!snapshot.exists){
        throw Exception("User Doesnt Exist");
      }
      int currentBalance = snapshot['wallet']['balance'];
      if (currentBalance<coins){
        throw Exception("Insufficient Balance!");
      }

      int newBalance = currentBalance - coins;
      transaction.update(userDoc,{
        'wallet.balance':newBalance,
        'wallet.rewardsHistory': FieldValue.arrayUnion([{
          'coins':-coins,
          'date':FieldValue.serverTimestamp(),
          'type':'redeem'
        }])
      });
    });
  }
}