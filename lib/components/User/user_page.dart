import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:restaurantapp/components/User/bill_history_page.dart';
import 'package:restaurantapp/components/User/carousal_page.dart';
import 'package:restaurantapp/components/User/history_page.dart';
import 'package:restaurantapp/components/User/rewards_page.dart';
import 'package:restaurantapp/components/User/upload_bill_page.dart';
import 'package:restaurantapp/components/User/menu_page.dart';
import 'package:restaurantapp/pages/bottom_navbar.dart';
import 'package:restaurantapp/pages/custom_aapbar.dart';
import 'package:restaurantapp/pages/login_page.dart';
import 'package:restaurantapp/pages/redeem_page.dart';

class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const CarousalPage(),
    const RewardsPage(),
    const HistoryPage(),
    const UploadBillPage(),
    MenuPage(),
  ];

  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _logout(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  Future<bool> _onWillPop() async {
    if (_currentIndex != 0) {
      setState(() {
        _currentIndex = 0;
      });
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: CustomAppBar(
          title: "CARATS",
          centerTitle: false,
          backgroundColor: const Color(0xFFC0392B),
        ),
        body: Container(
          color: const Color(0xFFFDF3E7), // Light Cream background color
          child: Stack(
            children: [
              _screens[_currentIndex],
              if (_currentIndex == 0) // Show buttons only on the CarousalPage
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 200),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const RewardsPage()),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16)),
                            child: const ListTile(
                              leading: Icon(Icons.wallet_giftcard),
                              title: Text("Rewards"),
                              contentPadding: EdgeInsets.symmetric(horizontal:10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const RedeemPage()),
                            );
                          },
                          child: const Text("Redeem Coupon"),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const HistoryPage()),
                            );
                          },
                          child: const Text("Transaction History"),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const UploadBillPage()),
                            );
                          },
                          child: const Text('Upload Bill'),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const BillPage()),
                            );
                          },
                          child: const Text('Bill History'),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => MenuPage()),
                            );
                          },
                          child: const Text('View Menu'),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}
