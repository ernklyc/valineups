import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:valineups/components/full_screen_image_viewer.dart';
import 'package:valineups/components/sides.dart';
import 'package:valineups/screens/player_items/agents.dart';
import 'package:valineups/screens/maps/maps_api.dart';
import 'package:valineups/screens/maps/maps_model.dart';
import 'package:valineups/styles/fonts.dart';
import 'package:valineups/styles/project_color.dart';
import 'package:valineups/utils/constants.dart';
import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
  late Future<List<MapModel>> futureMaps;
  List<MapModel> maps = [];
  late Future<void> futureLoadedImages;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    futureMaps = ApiService().fetchMaps();
    futureLoadedImages = _loadSavedMaps();
  }

  Future<void> _loadSavedMaps() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('lineups')
          .where('agentName', isEqualTo: widget.agentName)
          .get();

      List<Map<String, dynamic>> validMapsList = [];
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> map = doc.data() as Map<String, dynamic>;
        bool allImagesExist = true;
        for (String url in map['images']) {
          bool exists = await _checkImageExistence(url);
          if (!exists) {
            allImagesExist = false;
            break;
          }
        }
        if (allImagesExist) {
          validMapsList.add(map);
        }
      }
      setState(() {
        savedMaps = validMapsList;
      });
    } catch (e) {
      print("Error loading maps from Firestore: $e");
    }
  }

  Future<void> _saveMap(Map<String, dynamic> map) async {
    try {
      await FirebaseFirestore.instance.collection('lineups').add(map);
      setState(() {
        savedMaps.add(map);
      });
    } catch (e) {
      print("Error saving map to Firestore: $e");
    }
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

  Future<void> _uploadImages() async {
    final picker = ImagePicker();
    final List<XFile>? pickedFiles = await picker.pickMultiImage();

    if (pickedFiles != null) {
      if (pickedFiles.length > 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select a maximum of 3 images')),
        );
        return;
      }

      int groupNumber =
          (savedMaps.where((map) => map['side'] == selectedSide).length / 3)
                  .ceil() +
              1;
      List<String> uploadedUrls = [];
      for (var i = 0; i < pickedFiles.length; i++) {
        var file = pickedFiles[i];
        String fileName =
            'images/${widget.agentName}/${selectedMap}/${selectedSide}/group_${groupNumber}/image_${i + 1}.png';
        Reference storageRef = FirebaseStorage.instance.ref().child(fileName);

        await storageRef.putFile(File(file.path));
        String downloadUrl = await storageRef.getDownloadURL();
        uploadedUrls.add(downloadUrl);
      }

      // Save the image URLs to a map
      Map<String, dynamic> map = {
        'name': '${selectedMap}_${selectedSide}_group_${groupNumber}',
        'side': selectedSide,
        'agentName': widget.agentName,
        'images': uploadedUrls,
      };

      // Save to local storage
      await _saveMap(map);
    } else {
      // Show an error if no images are selected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select exactly 1 to 3 images')),
      );
    }
  }

  Future<bool> _checkImageExistence(String url) async {
    try {
      await FirebaseStorage.instance.refFromURL(url).getDownloadURL();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredMaps = savedMaps.where((map) {
      if (map['agentName'] != widget.agentName) {
        return false;
      }
      if (selectedMap != 'Maps' && map['name'].split('_')[0] != selectedMap) {
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
          FutureBuilder<List<MapModel>>(
            future: futureMaps,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Text('No maps found');
              } else {
                maps = snapshot.data!;
                if (!maps.any((map) => map.displayName == selectedMap)) {
                  selectedMap = maps[0].displayName;
                }
                return Column(
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
                        items: maps.map<DropdownMenuItem<String>>((map) {
                          return DropdownMenuItem<String>(
                            value: map.displayName,
                            child: Stack(
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
                                          image: NetworkImage(map.splash),
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
                                  map.displayName,
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
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
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
                                            MediaQuery.of(context).size.width /
                                                1.1,
                                        height: 150,
                                        color: ProjectColor()
                                            .dark
                                            .withOpacity(0.5),
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
                );
              }
            },
          ),
          Expanded(
            child: FutureBuilder<void>(
              future: futureLoadedImages,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error loading images'));
                } else if (filteredMaps.isEmpty) {
                  return Center(
                    child: Text(
                      'No images available.',
                      style: TextStyle(
                        color: ProjectColor().white,
                        fontSize: 18,
                      ),
                    ),
                  );
                } else {
                  return ListView.builder(
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
                                child: Image.network(
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
                                            setState(() {
                                              if (_isSaved(map)) {
                                                _removeMap(map);
                                              } else {
                                                _saveMap(map);
                                              }
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Side: ${map['side']}",
                                      style: TextStyle(
                                        color: ProjectColor()
                                            .white
                                            .withOpacity(0.7),
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
                  );
                }
              },
            ),
          ),
        ],
      ),
      persistentFooterButtons: _user?.email == 'ernklyc@gmail.com'
          ? [
              Center(
                child: ElevatedButton(
                  onPressed: _uploadImages,
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(ProjectColor().valoRed),
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
          FontAwesomeIcons.signOutAlt,
          color: ProjectColor().white,
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterFloat,
    );
  }
}
