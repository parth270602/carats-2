import 'package:flutter/material.dart';
import 'package:restaurantapp/pages/custom_aapbar.dart';
import 'package:restaurantapp/pages/drawer_page.dart';
import 'package:restaurantapp/services/history_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final HistoryService _historyService = HistoryService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: CustomAppBar(
        title: "CARATS",
      ),
      drawer: const DrawerPage(),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _historyService.getTransactionHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<Map<String, dynamic>> transactions = snapshot.data ?? [];
            return ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> transaction = transactions[index];
                bool isRedeem = transaction['type'] == 'redeem';
                return ListTile(
                  title: Text(transaction['description']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(transaction['date'].toDate().toString()),
                      if (isRedeem) Text('Status: ${transaction['status']}'),
                    ],
                  ),
                  trailing: Text('${transaction['amount']} coins'),
                );
              },
            );
          }
        },
      ),
    );
  }
}
