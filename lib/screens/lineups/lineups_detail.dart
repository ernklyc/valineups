import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:valineups/styles/project_color.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

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
        backgroundColor: ProjectColor().dark,
      ),
      backgroundColor: ProjectColor().dark,
      body: Padding(
        padding: const EdgeInsets.all(1.0),
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
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FullScreenImageGallery(
                                  imagePaths: imagePaths,
                                  initialIndex: _currentImageIndex,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            margin: EdgeInsets.symmetric(horizontal: 5.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.0),
                              image: DecorationImage(
                                image: NetworkImage(imagePath),
                                fit: BoxFit.fitWidth,
                              ),
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

class FullScreenImageGallery extends StatefulWidget {
  final List<String> imagePaths;
  final int initialIndex;

  FullScreenImageGallery(
      {required this.imagePaths, required this.initialIndex});

  @override
  _FullScreenImageGalleryState createState() => _FullScreenImageGalleryState();
}

class _FullScreenImageGalleryState extends State<FullScreenImageGallery> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ProjectColor().dark,
        title:
            Text("Image ${_currentIndex + 1} of ${widget.imagePaths.length}"),
      ),
      backgroundColor: ProjectColor().dark,
      body: PhotoViewGallery.builder(
        pageController: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemCount: widget.imagePaths.length,
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(widget.imagePaths[index]),
            initialScale: PhotoViewComputedScale.contained,
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
          );
        },
        scrollPhysics: BouncingScrollPhysics(),
        backgroundDecoration: BoxDecoration(
          color: ProjectColor().dark,
        ),
      ),
    );
  }
}
