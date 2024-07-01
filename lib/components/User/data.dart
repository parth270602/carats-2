import 'package:cloud_firestore/cloud_firestore.dart';

class CarouselDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<String>> fetchCarouselImages() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('carousal').get();
      if (snapshot.docs.isEmpty) {
        return [];
      }
      return snapshot.docs.map((doc) => doc['imageUrl'] as String).toList();
    } catch (e) {
      print('Error fetching carousel images: $e');
      return [];
    }
  }
}
