import 'package:flutter/material.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:valineups/styles/fonts.dart';
import 'package:valineups/styles/project_color.dart';

class WeaponSkinsScreen extends StatefulWidget {
  const WeaponSkinsScreen({super.key});

  @override
  _WeaponSkinsScreenState createState() => _WeaponSkinsScreenState();
}

class _WeaponSkinsScreenState extends State<WeaponSkinsScreen> {
  List<dynamic> _skins = [];
  List<dynamic> _filteredSkins = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchSkins();
    _searchController.addListener(_filterSkins);
  }

  Future<void> _fetchSkins() async {
    final response = await http
        .get(Uri.parse('https://valorant-api.com/v1/weapons/skinchromas'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _skins =
            data['data'].where((skin) => skin['displayIcon'] != null).toList();
        _filteredSkins = _skins;
      });
    } else {
      throw Exception('Failed to load skins');
    }
  }

  void _filterSkins() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredSkins = _skins.where((skin) {
        final skinName = skin['displayName'].toLowerCase();
        return skinName.contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          'WEAPONS SKINS',
          style: TextStyle(
            fontFamily: Fonts().valFonts,
            color: ProjectColor().white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
      backgroundColor: ProjectColor().dark,
      body: Column(
        children: [
          Expanded(
            child: _filteredSkins.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : Swiper(
                    loop: true,
                    viewportFraction: 0.35,
                    scale: 1,
                    scrollDirection: Axis.vertical,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _filteredSkins.length,
                    itemBuilder: (context, index) {
                      final skin = _filteredSkins[index];
                      String displayName = skin['displayName'] ?? '';
                      if (displayName.length > 10) {
                        displayName = '${displayName.substring(0, 10)}...';
                      }
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        color: ProjectColor().valoRed,
                        margin: const EdgeInsets.all(8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.network(
                                skin['displayIcon'],
                                fit: BoxFit.fitWidth,
                              ),
                              Positioned(
                                bottom: 20,
                                left: 15,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    displayName,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: Fonts().valFonts,
                                      shadows: [
                                        Shadow(
                                          color: ProjectColor().dark,
                                          blurRadius: 30,
                                        ),
                                      ],
                                      color: ProjectColor().white,
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0,
                                    ),
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
