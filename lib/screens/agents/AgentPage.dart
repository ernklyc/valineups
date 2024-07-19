import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:valineups/components/full_screen_image_viewer.dart';
import 'package:valineups/components/lineups_maps.dart';
import 'package:valineups/components/sides.dart';
import 'package:valineups/screens/home/agents.dart';
import 'package:valineups/styles/fonts.dart';
import 'package:valineups/styles/project_color.dart';
import 'package:valineups/utils/constants.dart';
import 'dart:convert';

class AgentPage extends StatefulWidget {
  final String agentName;
  final String agentImage;
  final List<Map<String, dynamic>> maps;

  const AgentPage({
    super.key,
    required this.agentName,
    required this.agentImage,
    required this.maps,
  });

  @override
  _AgentPageState createState() => _AgentPageState();
}

class _AgentPageState extends State<AgentPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  String selectedMap = 'Maps';
  String selectedSide = 'Side';
  List<Map<String, dynamic>> savedMaps = [];

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;

    _loadSavedMaps();
  }

  Future<void> _loadSavedMaps() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedMapsString = prefs.getString('savedMaps');
    if (savedMapsString != null) {
      setState(() {
        savedMaps =
            List<Map<String, dynamic>>.from(json.decode(savedMapsString));
      });
    }
  }

  Future<void> _saveMap(Map<String, dynamic> map) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      savedMaps.add(map);
    });
    await prefs.setString('savedMaps', json.encode(savedMaps));
  }

  Future<void> _removeMap(Map<String, dynamic> map) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      savedMaps.removeWhere((savedMap) => savedMap['name'] == map['name']);
    });
    await prefs.setString('savedMaps', json.encode(savedMaps));
  }

  bool _isSaved(Map<String, dynamic> map) {
    return savedMaps.any((savedMap) => savedMap['name'] == map['name']);
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredMaps = widget.maps.where((map) {
      if (selectedMap != 'Maps' && map['name'] != selectedMap) {
        return false;
      }
      if (selectedSide != 'Side' && map['side'] != selectedSide) {
        return false;
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: ProjectColor().dark,
        title: Text(
          "${widget.agentName} Lineups",
          style: TextStyle(
            color: ProjectColor().white,
            fontFamily: Fonts().valFonts,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: ProjectColor().dark,
      body: Column(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: DropdownButton<String>(
                  underline: Container(
                    height: 0,
                  ),
                  value: selectedMap,
                  alignment: Alignment.center,
                  elevation: 10,
                  icon: const Icon(Icons.arrow_drop_down_rounded),
                  dropdownColor: ProjectColor().dark,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedMap = newValue!;
                    });
                  },
                  //map dropdown
                  items: maps.map<DropdownMenuItem<String>>((map) {
                    return DropdownMenuItem<String>(
                      value: map['name']!,
                      child: map['name'] == 'Maps'
                          ? Center(
                              child: Text(
                                map['name']!,
                                style: TextStyle(
                                  color: ProjectColor().white,
                                  fontFamily: Fonts().valFonts,
                                ),
                              ),
                            )
                          : Stack(
                              alignment: Alignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: ClipRRect(
                                    borderRadius:
                                        ProjectBorderRadius().circular12,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width /
                                          1.1,
                                      height: 150,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage(
                                            map['image']!,
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width / 1.1,
                                  height: 150,
                                  color: ProjectColor().dark.withOpacity(0.5),
                                ),
                                Text(
                                  map['name']!,
                                  style: TextStyle(
                                    fontFamily: Fonts().valFonts,
                                    shadows: [
                                      Shadow(
                                        color: ProjectColor().white,
                                        blurRadius: 50,
                                      ),
                                    ],
                                    color: ProjectColor().white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 10,
                                  ),
                                ),
                              ],
                            ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(width: 10),
              Center(
                child: DropdownButton<String>(
                  underline: Container(
                    height: 0,
                  ),
                  value: selectedSide,
                  alignment: Alignment.center,
                  elevation: 10,
                  icon: const Icon(Icons.arrow_drop_down_rounded),
                  dropdownColor: ProjectColor().dark,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedSide = newValue!;
                    });
                  },
                  items: sides.map<DropdownMenuItem<String>>((side) {
                    return DropdownMenuItem<String>(
                      value: side['name']!,
                      child: side['name'] == 'Side'
                          ? Center(
                              child: Text(
                                side['name']!,
                                style: TextStyle(
                                  color: ProjectColor().white,
                                  fontFamily: Fonts().valFonts,
                                ),
                              ),
                            )
                          : Stack(
                              alignment: Alignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: ClipRRect(
                                    borderRadius:
                                        ProjectBorderRadius().circular12,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width /
                                          1.1,
                                      height: 150,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage(
                                            side['image']!,
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width / 1.1,
                                  height: 150,
                                  color: ProjectColor().dark.withOpacity(0.5),
                                ),
                                Text(
                                  side['name']!,
                                  style: TextStyle(
                                    fontFamily: Fonts().valFonts,
                                    shadows: [
                                      Shadow(
                                        color: ProjectColor().white,
                                        blurRadius: 50,
                                      ),
                                    ],
                                    color: ProjectColor().white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 10,
                                  ),
                                ),
                              ],
                            ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          //KARTLAR
          Expanded(
            child: ListView.builder(
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
                    margin: const EdgeInsets.all(8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    color: ProjectColor().dark.withOpacity(0.8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12.0)),
                          child: Image.asset(
                            map['images'][0],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 200,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    map['name'],
                                    style: TextStyle(
                                      color: ProjectColor().white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      _isSaved(map)
                                          ? Icons.bookmark
                                          : Icons.bookmark_border,
                                      color: ProjectColor().white,
                                    ),
                                    onPressed: () {
                                      if (_isSaved(map)) {
                                        _removeMap(map);
                                      } else {
                                        _saveMap(map);
                                      }
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Side: ${map['side']}",
                                style: TextStyle(
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
      persistentFooterButtons: _user?.email == 'ernklyc@gmail.com'
          ? [
              Center(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all(ProjectColor().valoRed),
                    fixedSize: MaterialStateProperty.all(
                      Size(
                        MediaQuery.of(context).size.width / 1.1,
                        50,
                      ),
                    ),
                  ),
                  child: FaIcon(
                    FontAwesomeIcons.add,
                    color: ProjectColor().white,
                  ),
                ),
              ),
            ]
          : null,
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        backgroundColor: ProjectColor().valoRed,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const Agents(),
            ),
          );
        },
        child: FaIcon(
          // ignore: deprecated_member_use
          FontAwesomeIcons.signOutAlt,
          color: ProjectColor().white,
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterFloat,
    );
  }
}
