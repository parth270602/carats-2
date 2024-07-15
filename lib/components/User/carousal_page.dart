import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';

class CarousalPage extends StatefulWidget {
  const CarousalPage({super.key});

  @override
  _CarousalPageState createState() => _CarousalPageState();
}

class _CarousalPageState extends State<CarousalPage> {
  final CarouselController _carouselController = CarouselController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _current = 0;
  List<String> _imageUrls = [];

  @override
  void initState() {
    super.initState();
    _fetchCarouselImages();
  }

  Future<void> _fetchCarouselImages() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('carousal').get();
      List<String> imageUrls = snapshot.docs.map((doc) => doc['imageUrl'] as String).toList();
      setState(() {
        _imageUrls = imageUrls;
      });
    } catch (e) {
      print('Error fetching images: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return _imageUrls.isEmpty
        ? const CircularProgressIndicator()
        : SizedBox(
            height: height * 0.3,  // Set a fixed height
            child: Stack(
              alignment: Alignment.center,
              children: [
                CarouselSlider(
                  carouselController: _carouselController,
                  options: CarouselOptions(
                    autoPlay: true,
                    enlargeCenterPage: true,
                    enableInfiniteScroll: true,
                    viewportFraction: 0.8,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _current = index;
                      });
                    },
                  ),
                  items: _imageUrls.map((url) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Image.network(url, fit: BoxFit.contain);
                      },
                    );
                  }).toList(),
                ),
                Positioned(
                  bottom: height * 0.02,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _imageUrls.asMap().entries.map((entry) {
                      bool isSelected = _current == entry.key;
                      return GestureDetector(
                        onTap: () => _carouselController.animateToPage(entry.key),
                        child: AnimatedContainer(
                          width: isSelected ? 20.0 : 10.0,
                          height: 10.0,
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.blue : Colors.grey,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          duration: const Duration(milliseconds: 300),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Positioned(
                  left: 15.0,
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.2),
                    child: IconButton(
                      onPressed: () {
                        _carouselController.previousPage();
                      },
                      icon: const Icon(Icons.arrow_back_ios, size: 20.0, color: Colors.white),
                    ),
                  ),
                ),
                Positioned(
                  right: 15.0,
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.2),
                    child: IconButton(
                      onPressed: () {
                        _carouselController.nextPage();
                      },
                      icon: const Icon(Icons.arrow_forward_ios, size: 20.0, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}