import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:restaurantapp/components/Admin/image_detail_page.dart';

class AdminImageApprovalPage extends StatefulWidget {
  const AdminImageApprovalPage({super.key});

  @override
  State<AdminImageApprovalPage> createState() => _AdminImageApprovalPageState();
}

class _AdminImageApprovalPageState extends State<AdminImageApprovalPage> {
  final FirebaseFirestore _firestore=FirebaseFirestore.instance;

  Future<void> _approveImage(String imageId,String userId) async{
    try{
      await _firestore.collection('images').doc(imageId).update({'approved':true});
      
      //award coins to users
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      int currentCoins = userDoc['wallet']['balance']??0;
      await _firestore.collection('users').doc(userId).update({
        'wallet.balance': currentCoins + 10
      });

    }catch(e){
      print('Failed to approve image');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Approve Images')),
      body:StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('images').where('approved',isEqualTo: false).snapshots(),
        builder: (context,snapshot){
          if(!snapshot.hasData){
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context,index){
              var image=snapshot.data!.docs[index];
              Timestamp timestamp=image['uploadedAt'];
              DateTime dateTime=timestamp.toDate();
              String formattedDate=DateFormat('dd-MM-yyyy HH:mm:ss').format(dateTime);
              return ListTile(
                leading: Image.network(image['url']),
                title: Text('Uploaded By: ${image['email']}'),
                subtitle: Text('Uploaded Date: $formattedDate'),
                onTap: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => ImageDetailPage(
                      imageUrl: image['url'], 
                      uploaderEmail: image['email'], 
                      uploadedAt: formattedDate,
                      ),
                      ),
                    );
                },
                trailing: IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () => _approveImage(image.id,image['userId']),
                ),
              );
            });
        },
        )
    );
  }
}