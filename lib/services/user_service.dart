import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService{
  final FirebaseFirestore _firestore=FirebaseFirestore.instance;
  final FirebaseAuth _auth=FirebaseAuth.instance;

  Future <void> registerUser(String email,String password) async{
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email, 
      password: password,
      );
      User? user=userCredential.user;

      if(user !=null){
        await _firestore.collection('users').doc(user.uid).set({
          'email':email,
          'createdAt':FieldValue.serverTimestamp(),
          'wallet':{
            'balance':100,
            'rewardsHistory':[],
          },
          'roll':'user'
        });
      }
  }
  Future<void> checkAndCreateWallet(User user) async{
    DocumentSnapshot doc=await _firestore.collection('users').doc(user.uid).get();
    Map<String,dynamic>? data=doc.data() as Map<String,dynamic>?;
    if(!doc.exists || !data!.containsKey('wallet')){
      await _firestore.collection('users').doc(user.uid).set({
        'wallet':{
          'balance':100,
          'rewardsHistory':[],
        }
      },SetOptions(merge: true));
    }
  }
}