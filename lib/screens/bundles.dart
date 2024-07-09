import 'package:flutter/material.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:valineups/styles/project_color.dart';

class BundlesPage extends StatefulWidget {
  const BundlesPage({super.key});

  @override
  _BundlesPageState createState() => _BundlesPageState();
}

class _BundlesPageState extends State<BundlesPage> {
  List<dynamic> bundles = [];

  @override
  void initState() {
    super.initState();
    fetchBundles();
  }

  Future<void> fetchBundles() async {
    final response =
        await http.get(Uri.parse('https://valorant-api.com/v1/bundles'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        bundles = data['data'];
      });
    } else {
      throw Exception('Failed to load bundles');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProjectColor().dark,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined,
              color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: ProjectColor().dark,
        title: const Text(
          'BUNDLES',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
      body: bundles.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Swiper(
              loop: true,
              viewportFraction: 0.35,
              scale: 1,
              scrollDirection: Axis.vertical,
              physics: const BouncingScrollPhysics(),
              itemCount: bundles.length,
              itemBuilder: (context, index) {
                final bundle = bundles[index];
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  color: ProjectColor().dark,
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const SizedBox(height: 8),
                        Image.network(
                          bundle['displayIcon'],
                          fit: BoxFit.fitHeight,
                          width: double.infinity,
                          height: 200,
                        ),
                        Positioned(
                          bottom: 30,
                          left: 10,
                          child: Text(
                            bundle['displayName'],
                            style: const TextStyle(
                              shadows: [
                                Shadow(
                                  color: Colors.black,
                                  blurRadius: 20,
                                ),
                              ],
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 15,
                          left: 10,
                          child: Text(
                            '${bundle['description'] ?? 'N/A'}',
                            style: const TextStyle(
                              shadows: [
                                Shadow(
                                  color: Colors.black,
                                  blurRadius: 30,
                                ),
                              ],
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
