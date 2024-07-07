import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:restaurantapp/components/User/bill_details_page.dart';
import 'package:restaurantapp/components/User/comment_widget.dart';
import 'package:restaurantapp/services/bill_history.dart';

class BillPage extends StatefulWidget {
  const BillPage({super.key});

  @override
  _BillPageState createState() => _BillPageState();
}

class _BillPageState extends State<BillPage> {
  final BillHistory _billHistory = BillHistory();
  bool _isLoading = true;
  List<Map<String, dynamic>> _bills = [];

  @override
  void initState() {
    super.initState();
    _loadBillHistory();
  }

  Future<void> _loadBillHistory() async {
    try {
      List<Map<String, dynamic>> bills = await _billHistory.getBillHistory();
      setState(() {
        _bills = bills;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading bill history: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bill History'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bills.isEmpty
              ? const Center(child: Text('No bills uploaded yet.'))
              : ListView.builder(
                  itemCount: _bills.length,
                  itemBuilder: (context, index) {
                    var bill = _bills[index];
                    Timestamp timestamp = bill['uploadedAt'];
                    DateTime dateTime = timestamp.toDate();
                    String formattedDate =
                        DateFormat('dd-MM-yyyy').format(dateTime);
                    bool isApproved = bill['approved'];
                    Color tileColor = isApproved
                        ? const Color.fromARGB(255, 165, 243, 169)
                        : Color.fromARGB(255, 245, 152, 145);
                    return Column(
                      children: [
                        const SizedBox(height: 5),
                        Container(
                          color: tileColor,
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => BillDetailsPage(
                                          imageUrl: bill['url'],
                                          uploadedAt: formattedDate,
                                          comments: bill['review'],
                                          status: bill['approved'],
                                          adminComments:
                                              bill['rejectionReason'],
                                        )),
                              );
                            },
                            leading: Image.network(bill['url']),
                            title: Text('Uploaded Date: $formattedDate'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Approved: ${bill['approved'] ? 'Yes' : 'No'}'),
                                CommentsWidget(
                                    comments: bill['rejectionReason']),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
    );
  }
}
