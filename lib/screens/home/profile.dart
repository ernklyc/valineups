import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:valineups/components/full_screen_image_viewer.dart';
import 'package:valineups/components/sides.dart';
import 'package:valineups/styles/fonts.dart';
import 'package:valineups/styles/project_color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Widget svgCode =
      RandomAvatar('saytoonz', trBackground: true, height: 50, width: 50);
  List<Map<String, dynamic>> savedMaps = [];

  String selectedMap = 'All';
  String selectedSide = 'All';
  String selectedAgent = 'All';
  List<dynamic> maps = [];
  List<String> agents = [];
  bool isLoadingMaps = true;
  bool isLoadingAgents = true;
  String searchText = '';

  @override
  void initState() {
    super.initState();
    _loadSavedLineups();
    _fetchMaps();
    _fetchAgents();
  }

  Future<void> _loadSavedLineups() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final lineupCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('savedLineups');
      final querySnapshot = await lineupCollection.get();
      if (mounted) {
        setState(() {
          savedMaps = querySnapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
        });
      }
    }
  }

  Future<void> _fetchMaps() async {
    final response =
        await http.get(Uri.parse('https://valorant-api.com/v1/maps'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (mounted) {
        setState(() {
          maps = data['data'];
          isLoadingMaps = false;
        });
      }
    } else {
      throw Exception('Failed to load maps');
    }
  }

  Future<void> _fetchAgents() async {
    final response = await http.get(Uri.parse(
        'https://valorant-api.com/v1/agents?isPlayableCharacter=true'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      if (mounted) {
        setState(() {
          agents = ['All'];
          for (var agent in data) {
            agents.add(agent['displayName']);
          }
          isLoadingAgents = false;
        });
      }
    } else {
      throw Exception('Failed to load agents');
    }
  }

  Future<void> _removeMap(Map<String, dynamic> map) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final lineupCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('savedLineups');
      final querySnapshot =
          await lineupCollection.where('name', isEqualTo: map['name']).get();
      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
      if (mounted) {
        setState(() {
          savedMaps.remove(map);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredMaps = savedMaps.where((map) {
      final mapMatches = searchText.isEmpty ||
          map['mapName']
              .toString()
              .toLowerCase()
              .contains(searchText.toLowerCase());
      final sideMatches = selectedSide == 'All' ||
          map['side']
              .toString()
              .toLowerCase()
              .contains(selectedSide.toLowerCase());
      final agentMatches = selectedAgent == 'All' ||
          map['agentName']
              .toString()
              .toLowerCase()
              .contains(selectedAgent.toLowerCase());
      return mapMatches && sideMatches && agentMatches;
    }).toList();

    return Scaffold(
      backgroundColor: ProjectColor().dark,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 32.0, bottom: 16.0),
            child: Text(
              "SAVED LINEUPS",
              style: TextStyle(
                fontFamily: Fonts().valFonts,
                color: ProjectColor().white,
                fontSize: 22,
                letterSpacing: 5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: ProjectColor().dark,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: DropdownButton<String>(
                      underline: Container(
                        height: 1,
                        color: ProjectColor().white,
                      ),
                      alignment: Alignment.center,
                      value: selectedSide,
                      icon: Icon(
                        Icons.arrow_drop_down_rounded,
                        color: ProjectColor().white,
                      ),
                      onChanged: (String? newValue) {
                        if (mounted) {
                          setState(() {
                            selectedSide = newValue!;
                          });
                        }
                      },
                      items: [
                        DropdownMenuItem<String>(
                          value: 'All',
                          child: Center(
                            child: Text(
                              'SIDE',
                              style: TextStyle(
                                color: ProjectColor().white,
                                fontFamily: Fonts().valFonts,
                              ),
                            ),
                          ),
                        ),
                        ...sides.map((side) {
                          return DropdownMenuItem<String>(
                            value: side['name'],
                            child: Center(
                              child: Text(
                                side['name']!,
                                style: TextStyle(
                                  color: ProjectColor().white,
                                  fontFamily: Fonts().valFonts,
                                ),
                              ),
                            ),
                          );
                        }).toList()
                      ],
                      dropdownColor: ProjectColor().dark,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  isLoadingAgents
                      ? Center(child: CircularProgressIndicator())
                      : Container(
                          decoration: BoxDecoration(
                            color: ProjectColor().dark,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: DropdownButton<String>(
                            underline: Container(
                              height: 1,
                              color: ProjectColor().white,
                            ),
                            alignment: Alignment.center,
                            value: selectedAgent,
                            icon: Icon(
                              Icons.arrow_drop_down_rounded,
                              color: ProjectColor().white,
                            ),
                            onChanged: (String? newValue) {
                              if (mounted) {
                                setState(() {
                                  selectedAgent = newValue!;
                                });
                              }
                            },
                            items: agents.map((agent) {
                              return DropdownMenuItem<String>(
                                  value: agent,
                                  child: Center(
                                    child: Text(
                                      agent,
                                      style: TextStyle(
                                        color: ProjectColor().white,
                                        fontFamily: Fonts().valFonts,
                                      ),
                                    ),
                                  ));
                            }).toList(),
                            dropdownColor: ProjectColor().dark,
                          ),
                        ),
                ],
              ),
            ],
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: filteredMaps.length,
              itemBuilder: (context, index) {
                var map = filteredMaps[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullScreenImageViewer(
                          images: List<String>.from(map['images']),
                        ),
                      ),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    color: ProjectColor().dark.withOpacity(0.8),
                    elevation: 5,
                    shadowColor: Colors.black45,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12.0)),
                          child: Image.network(
                            map['images'][0],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 100,
                            loadingBuilder: (context, child, progress) {
                              return progress == null
                                  ? child
                                  : Center(child: CircularProgressIndicator());
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey,
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.broken_image,
                                  color: Colors.white,
                                  size: 50,
                                ),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      map['name'],
                                      style: TextStyle(
                                        fontFamily: Fonts().valFonts,
                                        color: ProjectColor().white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      maxLines: 1,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.remove_circle_outline,
                                      color: ProjectColor().white,
                                    ),
                                    onPressed: () {
                                      _removeMap(map);
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Side: ${map['side']}",
                                style: TextStyle(
                                  fontFamily: Fonts().valFonts,
                                  color: ProjectColor().white.withOpacity(0.7),
                                  fontSize: 14,
                                ),
                              ),
                            ],
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
