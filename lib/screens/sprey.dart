import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:valineups/styles/fonts.dart';
import 'package:valineups/styles/project_color.dart';

class SprayListScreen extends StatefulWidget {
  const SprayListScreen({super.key});

  @override
  _SprayListScreenState createState() => _SprayListScreenState();
}

class _SprayListScreenState extends State<SprayListScreen> {
  List<Spray> sprays = [];

  @override
  void initState() {
    super.initState();
    fetchSprays();
  }

  Future<void> fetchSprays() async {
    final response =
        await http.get(Uri.parse('https://valorant-api.com/v1/sprays'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        sprays = (data['data'] as List).map((e) => Spray.fromJson(e)).toList();
      });
    } else {
      throw Exception('Failed to load sprays');
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
          'SPREYS',
          style: TextStyle(
            fontFamily: Fonts().valFonts,
            color: ProjectColor().white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
      body: sprays.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7, // Kartların boyutu
              ),
              itemCount: sprays.length,
              itemBuilder: (context, index) {
                final spray = sprays[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    color: ProjectColor().valoRed,
                    child: Column(
                      children: [
                        Expanded(
                          child: Image.network(
                            spray.fullIcon ?? spray.displayIcon,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            spray.truncatedDisplayName,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: Fonts().valFonts,
                              color: ProjectColor().white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
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

class Spray {
  final String uuid;
  final String displayName;
  final String displayIcon;
  final String? fullIcon;

  Spray({
    required this.uuid,
    required this.displayName,
    required this.displayIcon,
    required this.fullIcon,
  });

  factory Spray.fromJson(Map<String, dynamic> json) {
    return Spray(
      uuid: json['uuid'],
      displayName: json['displayName'],
      displayIcon: json['displayIcon'],
      fullIcon: json['fullIcon'],
    );
  }

  String get truncatedDisplayName {
    return displayName.length > 5
        ? '${displayName.substring(0, 5)}...'
        : displayName;
  }
}
