import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Valorant Competitive Tiers',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CompetitiveTiersScreen(),
    );
  }
}

class CompetitiveTiersScreen extends StatefulWidget {
  @override
  _CompetitiveTiersScreenState createState() => _CompetitiveTiersScreenState();
}

class _CompetitiveTiersScreenState extends State<CompetitiveTiersScreen> {
  Future<List<Tier>>? _futureTiers;

  @override
  void initState() {
    super.initState();
    _futureTiers = fetchTiers();
  }

  Future<List<Tier>> fetchTiers() async {
    final response = await http
        .get(Uri.parse('https://valorant-api.com/v1/competitivetiers'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<Tier> tiers = [];
      for (var tier in data['data'][0]['tiers']) {
        tiers.add(Tier.fromJson(tier));
      }
      return tiers;
    } else {
      throw Exception('Failed to load tiers');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Valorant Competitive Tiers'),
      ),
      body: FutureBuilder<List<Tier>>(
        future: _futureTiers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data available'));
          }

          final tiers = snapshot.data!;
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              childAspectRatio: 0.7,
            ),
            itemCount: tiers.length,
            itemBuilder: (context, index) {
              final tier = tiers[index];
              return Card(
                margin: EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: tier.largeIcon != null
                            ? Image.network(tier.largeIcon!)
                            : SizedBox.shrink(),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        tier.tierName,
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        tier.divisionName,
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class Tier {
  final int tier;
  final String tierName;
  final String divisionName;
  final String color;
  final String backgroundColor;
  final String? smallIcon;
  final String? largeIcon;
  final String? rankTriangleDownIcon;
  final String? rankTriangleUpIcon;

  Tier({
    required this.tier,
    required this.tierName,
    required this.divisionName,
    required this.color,
    required this.backgroundColor,
    this.smallIcon,
    this.largeIcon,
    this.rankTriangleDownIcon,
    this.rankTriangleUpIcon,
  });

  factory Tier.fromJson(Map<String, dynamic> json) {
    return Tier(
      tier: json['tier'],
      tierName: json['tierName'],
      divisionName: json['divisionName'],
      color: json['color'],
      backgroundColor: json['backgroundColor'],
      smallIcon: json['smallIcon'],
      largeIcon: json['largeIcon'],
      rankTriangleDownIcon: json['rankTriangleDownIcon'],
      rankTriangleUpIcon: json['rankTriangleUpIcon'],
    );
  }
}
