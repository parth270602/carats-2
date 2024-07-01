import "package:flutter/material.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import 'package:carousel_slider/carousel_slider.dart';


class CarousalPage extends StatelessWidget {
  final FirebaseFirestore _firestore=FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:Text('Carousal Page'),
      ),
      body:Center(
        child: FutureBuilder<QuerySnapshot>(
          future: _firestore.collection('carousal').get(),
          builder: (context,snapshot){
            if(snapshot.connectionState==ConnectionState.waiting){
              return CircularProgressIndicator();
            }
            if (snapshot.hasError){
              return Text('Error ${snapshot.error}');
            }
            if(!snapshot.hasData || snapshot.data!.docs.isEmpty){
              return Text('No images available');
            }
            List<String> imageUrls=snapshot.data!.docs.map((doc) =>doc['imageUrl'] as String).toList();


            return CarouselSlider(
              items: imageUrls.map((url){
                return Image.network(url,fit:BoxFit.cover);
              }).toList(), 
              options: CarouselOptions(
                height: 300.0,
                enlargeCenterPage: true,
                autoPlay: true,
                aspectRatio: 16/9,
                autoPlayCurve: Curves.fastOutSlowIn,
                enableInfiniteScroll: true,
                autoPlayAnimationDuration: Duration(milliseconds: 800),
                viewportFraction: 0.8
              ),
              );
          },
        ),
        )
    );
  }
}