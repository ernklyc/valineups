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
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WeaponSkinsScreen(),
    );
  }
}

class WeaponSkinsScreen extends StatefulWidget {
  @override
  _WeaponSkinsScreenState createState() => _WeaponSkinsScreenState();
}

class _WeaponSkinsScreenState extends State<WeaponSkinsScreen> {
  List<dynamic> _skins = [];
  List<dynamic> _filteredSkins = [];
  TextEditingController _searchController = TextEditingController();

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
        _skins = data['data'];
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
        title: Text('Weapon Skins'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          Expanded(
            child: _filteredSkins.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _filteredSkins.length,
                    itemBuilder: (context, index) {
                      final skin = _filteredSkins[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                        margin:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(15)),
                              child: skin['displayIcon'] != null
                                  ? Image.network(
                                      skin['displayIcon'],
                                      fit: BoxFit.fitWidth,
                                      width: double.infinity,
                                      height: 200,
                                    )
                                  : Container(
                                      width: double.infinity,
                                      height: 200,
                                      color: Colors.grey[300],
                                      child: Center(child: Text('No Image')),
                                    ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                skin['displayName'],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.start,
                              ),
                            ),
                          ],
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
