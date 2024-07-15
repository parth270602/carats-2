import 'package:flutter/material.dart';
import 'package:restaurantapp/components/User/history_page.dart';
import 'package:restaurantapp/components/User/menu_page.dart';
import 'package:restaurantapp/components/User/rewards_page.dart';
import 'package:restaurantapp/components/User/upload_bill_page.dart';
import 'package:restaurantapp/pages/home_page.dart';

class DrawerPage extends StatefulWidget {
  const DrawerPage({super.key});
  @override
  State<DrawerPage> createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFFDF3E7),
      shadowColor: const Color(0xFFE67E22),
      child: Container(
        child: ListView(
          children: [
            const DrawerHeader(
              child: Text(
                "C A R A T S",
                style: TextStyle(fontSize: 35,
                color: Color(0xFFE67E22)
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home',
              style:TextStyle(fontSize: 20, color: Color(0xFFE67E22)), ),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const HomePage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.card_giftcard),
              title: const Text('Rewards',
              style:TextStyle(fontSize: 20, color: Color(0xFFE67E22)),),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const RewardsPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('History',
              style:TextStyle(fontSize: 20, color: Color(0xFFE67E22)),),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const HistoryPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.upload_file),
              title: const Text('Upload Bill',
              style:TextStyle(fontSize: 20, color: Color(0xFFE67E22)),),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const UploadBillPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.restaurant_menu_sharp),
              title: const Text('Menu',
              style:TextStyle(fontSize: 20, color: Color(0xFFE67E22)),),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => MenuPage()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
