import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Valorant Sprays',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SprayListScreen(),
    );
  }
}

class SprayListScreen extends StatefulWidget {
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
      appBar: AppBar(
        title: Text('Valorant Sprays'),
      ),
      body: sprays.isEmpty
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7, // Kartların boyutu
              ),
              itemCount: sprays.length,
              itemBuilder: (context, index) {
                final spray = sprays[index];
                return Card(
                  child: Column(
                    children: [
                      Expanded(
                        child: Image.network(
                          spray.fullIcon ?? spray.displayIcon,
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          spray.displayName,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
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
}
