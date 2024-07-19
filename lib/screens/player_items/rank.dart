import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:valineups/styles/fonts.dart';
import 'dart:convert';

import 'package:valineups/styles/project_color.dart';

class CompetitiveTiersScreen extends StatefulWidget {
  const CompetitiveTiersScreen({super.key});

  @override
  _CompetitiveTiersScreenState createState() => _CompetitiveTiersScreenState();
}

class _CompetitiveTiersScreenState extends State<CompetitiveTiersScreen> {
  Future<List<Tier>>? _futureTiers;

  @override
  void initState() {
    super.initState();
    _futureTiers = fetchTiers('03621f52-342b-cf4e-4f86-9350a49c6d04');
  }

  Future<List<Tier>> fetchTiers(String uuid) async {
    final response = await http
        .get(Uri.parse('https://valorant-api.com/v1/competitivetiers'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<Tier> tiers = [];
      for (var tier in data['data']) {
        if (tier['uuid'] == uuid) {
          for (var t in tier['tiers']) {
            tiers.add(Tier.fromJson(t));
          }
        }
      }
      return tiers;
    } else {
      throw Exception('Failed to load tiers');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProjectColor().dark,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_outlined,
            color: ProjectColor().white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: ProjectColor().dark,
        title: Text(
          'TIERS',
          style: TextStyle(
            fontFamily: Fonts().valFonts,
            color: ProjectColor().white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
      body: FutureBuilder<List<Tier>>(
        future: _futureTiers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerEffect();
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data available'));
          }

          final tiers = snapshot.data!;
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              childAspectRatio: 0.7,
            ),
            itemCount: tiers.length,
            itemBuilder: (context, index) {
              final tier = tiers[index];
              return Card(
                color: ProjectColor().dark,
                margin: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: tier.largeIcon != null
                            ? Image.network(tier.largeIcon!)
                            : const SizedBox.shrink(),
                      ),
                      Text(
                        tier.divisionName,
                        style: TextStyle(
                            fontFamily: Fonts().valFonts,
                            fontSize: 14.0,
                            color: ProjectColor().white,
                            fontWeight: FontWeight.w800),
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

  Widget _buildShimmerEffect() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 0.7,
      ),
      itemCount: 9,
      itemBuilder: (context, index) {
        return Card(
          color: ProjectColor().dark,
          margin: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              enabled: true,
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      color: Colors.grey,
                    ),
                  ),
                  Container(
                    height: 20.0,
                    color: Colors.grey,
                    margin: const EdgeInsets.only(top: 8.0),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
