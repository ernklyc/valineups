import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Model sınıfı
class LevelBorder {
  final String uuid;
  final String displayName;
  final int startingLevel;
  final String levelNumberAppearance;
  final String smallPlayerCardAppearance;
  final String assetPath;

  LevelBorder({
    required this.uuid,
    required this.displayName,
    required this.startingLevel,
    required this.levelNumberAppearance,
    required this.smallPlayerCardAppearance,
    required this.assetPath,
  });

  factory LevelBorder.fromJson(Map<String, dynamic> json) {
    return LevelBorder(
      uuid: json['uuid'],
      displayName: json['displayName'],
      startingLevel: json['startingLevel'],
      levelNumberAppearance: json['levelNumberAppearance'],
      smallPlayerCardAppearance: json['smallPlayerCardAppearance'],
      assetPath: json['assetPath'],
    );
  }
}

// API'den veri çeken fonksiyon
Future<List<LevelBorder>> fetchLevelBorders() async {
  final response =
      await http.get(Uri.parse('https://valorant-api.com/v1/levelborders'));

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body)['data'];
    return jsonResponse.map((data) => LevelBorder.fromJson(data)).toList();
  } else {
    throw Exception('Veri yüklenirken bir hata oluştu.');
  }
}

class LevelBorderListScreen extends StatefulWidget {
  const LevelBorderListScreen({super.key});

  @override
  _LevelBorderListScreenState createState() => _LevelBorderListScreenState();
}

class _LevelBorderListScreenState extends State<LevelBorderListScreen> {
  late Future<List<LevelBorder>> futureLevelBorders;

  @override
  void initState() {
    super.initState();
    futureLevelBorders = fetchLevelBorders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Level Borders'),
      ),
      body: Center(
        child: FutureBuilder<List<LevelBorder>>(
          future: futureLevelBorders,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<LevelBorder> data = snapshot.data!;
              return ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final levelBorder = data[index];
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.network(
                            levelBorder.smallPlayerCardAppearance,
                            height: 80,
                            width: double.infinity,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            levelBorder.displayName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('Starting Level: ${levelBorder.startingLevel}'),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }

            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Valorant Level Borders',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LevelBorderListScreen(),
    );
  }
}
