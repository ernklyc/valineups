import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
      appBar: AppBar(
        title: const Text('Valorant Weapons'),
      ),
      body: weapons.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: weapons.length,
              itemBuilder: (context, index) {
                final weapon = weapons[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.network(
                          weapon['displayIcon'],
                          height: 80,
                          width: double.infinity,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          weapon['displayName'],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                            'Cost: ${weapon['shopData'] != null ? weapon['shopData']['cost'].toString() : 'N/A'}'),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
