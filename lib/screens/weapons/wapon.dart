import 'package:flutter/material.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:http/http.dart' as http;
import 'package:valineups/styles/fonts.dart';
import 'dart:convert';

import 'package:valineups/styles/project_color.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Valorant Weapons',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const WeaponsPage(),
    );
  }
}

class WeaponsPage extends StatefulWidget {
  const WeaponsPage({super.key});

  @override
  _WeaponsPageState createState() => _WeaponsPageState();
}

class _WeaponsPageState extends State<WeaponsPage> {
  List<dynamic> weapons = [];

  @override
  void initState() {
    super.initState();
    fetchWeapons();
  }

  Future<void> fetchWeapons() async {
    final response =
        await http.get(Uri.parse('https://valorant-api.com/v1/weapons'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        weapons = data['data'];
      });
    } else {
      throw Exception('Failed to load weapons');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProjectColor().dark,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_outlined,
              color: ProjectColor().white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: ProjectColor().dark,
        title: Text(
          'WEAPONS',
          style: TextStyle(
            fontFamily: Fonts().valFonts,
            color: ProjectColor().white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
      body: weapons.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Swiper(
              loop: true,
              viewportFraction: 0.35,
              scale: 1,
              scrollDirection: Axis.vertical,
              physics: const BouncingScrollPhysics(),
              itemCount: weapons.length,
              itemBuilder: (context, index) {
                final weapon = weapons[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  color: ProjectColor().valoRed,
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const SizedBox(height: 8),
                        Image.network(
                          weapon['displayIcon'],
                          fit: BoxFit.fitWidth,
                          width: double.infinity,
                          height: 200,
                        ),
                        Positioned(
                          bottom: 30,
                          left: 10,
                          child: Text(
                            weapon['displayName'],
                            style: TextStyle(
                              fontFamily: Fonts().valFonts,
                              shadows: [
                                Shadow(
                                  color: ProjectColor().dark,
                                  blurRadius: 20,
                                ),
                              ],
                              color: ProjectColor().white,
                              fontSize: 54,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 15,
                          left: 10,
                          child: Text(
                            'Cost: ${weapon['shopData'] != null ? weapon['shopData']['cost'].toString() : 'N/A'}',
                            style: TextStyle(
                              fontFamily: Fonts().valFonts,
                              shadows: [
                                Shadow(
                                  color: ProjectColor().dark,
                                  blurRadius: 30,
                                ),
                              ],
                              color: ProjectColor().white,
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
