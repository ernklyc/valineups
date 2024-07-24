import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:valineups/styles/project_color.dart';

class LineupDetailScreen extends StatefulWidget {
  final DocumentSnapshot lineup;

  LineupDetailScreen({required this.lineup});

  @override
  _LineupDetailScreenState createState() => _LineupDetailScreenState();
}

class _LineupDetailScreenState extends State<LineupDetailScreen> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final imagePaths = List<String>.from(widget.lineup['imagePaths']);
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.circle, color: ProjectColor().dark),
            onPressed: () {},
          ),
        ],
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ProjectColor().white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              widget.lineup['mapName'].toString().toUpperCase(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ProjectColor().white,
              ),
            ),
            Text(
              "|",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ProjectColor().white,
              ),
            ),
            Text(
              widget.lineup['side'].toString().toUpperCase(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ProjectColor().white,
              ),
            ),
            Text(
              "|",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ProjectColor().white,
              ),
            ),
            Text(
              widget.lineup['agentName'].toString().toUpperCase(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ProjectColor().white,
              ),
            ),
          ],
        ),
        backgroundColor: ProjectColor().dark,
      ),
      backgroundColor: ProjectColor().dark,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                CarouselSlider(
                  options: CarouselOptions(
                    height: 400.0,
                    viewportFraction: 1.0,
                    enlargeCenterPage: false,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                  ),
                  items: imagePaths.map((imagePath) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          width: MediaQuery.of(context).size.width / 2,
                          margin: EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            image: DecorationImage(
                              image: NetworkImage(imagePath),
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
                SizedBox(height: 10),
                Center(
                  child: AnimatedSmoothIndicator(
                    activeIndex: _currentImageIndex,
                    count: imagePaths.length,
                    effect: ScrollingDotsEffect(
                      activeDotColor: ProjectColor().white,
                      dotColor: ProjectColor().white.withOpacity(0.5),
                      dotHeight: 8.0,
                      dotWidth: 8.0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
