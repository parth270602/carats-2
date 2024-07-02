import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:restaurantapp/services/coupon_service.dart';

class CouponPage extends StatefulWidget {
  const CouponPage({super.key});

  @override
  State<CouponPage> createState() => _CouponPageState();
}

class _CouponPageState extends State<CouponPage> {
  final FirebaseAuth _auth=FirebaseAuth.instance;
  final FirebaseFirestore _firestore=FirebaseFirestore.instance;
  final CouponService _couponService=CouponService();
  @override
   Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return _buildCouponUI(snapshot.data);
          }
        },
      ),
    );
  }
  Future<Map<String,dynamic>?> _getUserData() async{
    User? user=_auth.currentUser;
    if(user==null) return null;

    try{
      DocumentSnapshot doc=await _firestore.collection('users').doc(user.uid).get();
      return doc.data() as Map<String,dynamic>?;
    }catch(e){
      print('Error fetching user data: $e');
      return null;
    }
  }


  Widget _buildCouponUI(Map<String,dynamic>? userData){
    if(userData==null){
      return const Center(child: Text("User Data not found"));
    }

    int balance= userData['wallet']['balance'] ?? 0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Wallet Balance: $balance coins',
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            _buyCoupon('10% off',100);
          }, 
          child: const Text('Buy 10% off Coupon for 100 coins'))
      ],
    );
  }

  void _buyCoupon(String couponType,int coinCost){
    _couponService.createCoupon(couponType, coinCost).then((_){
      setState(() {});//refresh ui
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coupon purchased successfully! Awaiting admin approval.')),
      );
    }).catchError((error){
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to purchase coupon: $error')),
      );
    });
  }
}