import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MenuPage extends StatelessWidget {
  MenuPage({super.key});
  final FirebaseFirestore _firestore=FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),

      ),body: StreamBuilder(
        stream: _firestore.collection('menu').snapshots(),
        builder: (context,AsyncSnapshot<QuerySnapshot> snapshot){
          if(snapshot.hasError){
            return Center(child: Text("Error : ${snapshot.error}"));
          }
          if(snapshot.connectionState== ConnectionState.waiting){
            return Center(child: CircularProgressIndicator());

          }
          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document){
              Map<String,dynamic> data=document.data() as Map<String,dynamic>;
              String base64String=data['base64Image'];
              return ListTile(
                title:Base64ImageWidget(base64String: base64String),

              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class Base64ImageWidget extends StatelessWidget {
  final String base64String;
  const Base64ImageWidget({super.key, required this.base64String});

  @override
  Widget build(BuildContext context) {
    Uint8List bytes=base64Decode(base64String);
    return Image.memory(
      bytes,
      fit:BoxFit.cover,
    );
  }
}