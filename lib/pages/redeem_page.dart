import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:restaurantapp/services/redeem_service.dart';

class RedeemPage extends StatefulWidget {
  const RedeemPage({super.key});

  @override
  State<RedeemPage> createState() => _RedeemPageState();
}

class _RedeemPageState extends State<RedeemPage> {
  final RedeemService _redeemService = RedeemService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> _getUserData() async {
    User? user = _auth.currentUser;
    if (user == null) return null;

    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(user.uid).get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }

  void _redeemCoins(int coinAmount) async {
    try {
      await _redeemService.requestRedeem(coinAmount);
      setState(() {}); //refresh
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Redeemption request submitted sucessfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit redemption request: $e')),
      );
    }
  }

  void _showRedeemDialog(int balance) {
    final TextEditingController _dialogAmountController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Redeem Coins"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _dialogAmountController,
                decoration: const InputDecoration(
                  labelText: "Enter coin amount",
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                children: [
                  _buildPercentageButton(_dialogAmountController, balance, 25),
                  _buildPercentageButton(_dialogAmountController, balance, 50),
                  _buildPercentageButton(_dialogAmountController, balance, 75),
                  _buildPercentageButton(_dialogAmountController, balance, 100),
                ],
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                int coinAmount =
                    int.tryParse(_dialogAmountController.text) ?? 0;
                if (coinAmount > 0 && coinAmount <= balance) {
                  _redeemCoins(coinAmount);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Failed to submit redemption request:')),
                  );
                }
              },
              child: const Text("Redeem"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPercentageButton(TextEditingController controller,int balance,int percentage){
    return ElevatedButton(
      onPressed: () {
        int calculatedAmount=(balance * (percentage/100)).round();
        controller.text=calculatedAmount.toString();
      }, 
      child: Text('$percentage%'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:FutureBuilder<Map<String,dynamic>?>(
        future:_getUserData(),
        builder:(context,snapshot){
          if(snapshot.connectionState==ConnectionState.waiting){
            return const CircularProgressIndicator();
          }
          else if(snapshot.hasError){
            return Center(child: Text('Error: ${snapshot.error}'));
          }else{
            Map<String,dynamic>? userData=snapshot.data;
            int balance=userData?['wallet']['balance'] ?? 0;


            return  Padding(
              padding: const  EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    "Wallet Balance: $balance coins",
                    style:const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _showRedeemDialog(balance);
                    }, 
                    child: const Text('Redeem Coins'),
                    ),
                ],
              ),
              );
          }
        }
      )
    );
  }
}
