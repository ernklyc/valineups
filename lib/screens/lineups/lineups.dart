import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:valineups/components/sides.dart';
import 'package:valineups/screens/lineups/lineups_detail.dart';
import 'package:valineups/screens/lineups/lineups_home.dart';
import 'package:valineups/styles/fonts.dart';
import 'package:valineups/styles/project_color.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LineupListScreen extends StatefulWidget {
  @override
  State<LineupListScreen> createState() => _LineupListScreenState();
}

class _LineupListScreenState extends State<LineupListScreen> {
  final _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  Set<String> _savedLineups = Set<String>();

  String searchText = '';

  String selectedMap = 'All';
  String selectedSide = 'All';
  String selectedAgent = 'All';
  List<dynamic> maps = [];
  List<String> agents = [];

  bool isLoadingMaps = true;
  bool isLoadingAgents = true;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _loadSavedLineups();
    _fetchMaps();
    _fetchAgents();
  }

  Future<void> _loadSavedLineups() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final lineupCollection = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('savedLineups');
      final querySnapshot = await lineupCollection.get();
      if (mounted) {
        setState(() {
          _savedLineups = querySnapshot.docs.map((doc) => doc.id).toSet();
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

  Future<void> _saveLineup(String lineupId, Map<String, dynamic> lineup) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final lineupCollection = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('savedLineups');
      await lineupCollection.doc(lineupId).set(lineup);
      if (mounted) {
        setState(() {
          _savedLineups.add(lineupId);
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lineup Saved.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kullanıcı oturum açmamış.')),
      );
    }
  }

  Future<void> _removeLineup(String lineupId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final lineupCollection = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('savedLineups');
      await lineupCollection.doc(lineupId).delete();
      if (mounted) {
        setState(() {
          _savedLineups.remove(lineupId);
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lineup kaldırıldı.')),
      );
    }
  }

  void _toggleSaveLineup(String lineupId, Map<String, dynamic> lineup) {
    if (_savedLineups.contains(lineupId)) {
      _removeLineup(lineupId);
    } else {
      _saveLineup(lineupId, lineup);
    }
  }

  Future<void> _deleteLineup(
      BuildContext context, String lineupId, List<String> imagePaths) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email == 'valineupstr@gmail.com') {
      final confirmation = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: ProjectColor().valoRed,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'Silmek istediginine misiniz?',
              style: TextStyle(
                color: ProjectColor().white,
                fontFamily: Fonts().valFonts,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'Bu işlem geri alınamaz.',
              style: TextStyle(
                color: ProjectColor().white.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
            actions: [
              ElevatedButton(
                child: Text(
                  'Hayır',
                  style: TextStyle(
                    color: ProjectColor().valoRed,
                    fontFamily: Fonts().valFonts,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ProjectColor().white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              ElevatedButton(
                child: Text(
                  'Evet',
                  style: TextStyle(
                    color: ProjectColor().white,
                    fontFamily: Fonts().valFonts,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ProjectColor().dark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          );
        },
      );

      if (confirmation == true) {
        // Silme işlemi burada gerçekleştirilir
        await _firestore.collection('lineups').doc(lineupId).delete();
        for (String path in imagePaths) {
          final ref = FirebaseStorage.instance.refFromURL(path);
          await ref.delete();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Lineup başarıyla silindi.',
              style: TextStyle(
                fontFamily: Fonts().valFonts,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: ProjectColor().valoRed,
          ),
        );
      }

      if (confirmation == true) {
        await _firestore.collection('lineups').doc(lineupId).delete();
        for (String path in imagePaths) {
          final ref = FirebaseStorage.instance.refFromURL(path);
          await ref.delete();
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bu işlemi yapma yetkiniz yok.')),
      );
    }
  }

  void _openLineupsHome(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: LineupsHome(),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProjectColor().dark,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
            child: TextField(
              style: TextStyle(color: ProjectColor().white),
              decoration: InputDecoration(
                hintText: 'Search lineups or your name...',
                hintStyle:
                    TextStyle(color: ProjectColor().white.withOpacity(0.5)),
                prefixIcon: Icon(Icons.search, color: ProjectColor().white),
                filled: true,
                fillColor: ProjectColor().dark,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: ProjectColor().white),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: ProjectColor().valoRed),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    isLoadingMaps
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
                                  offset: Offset(
                                      0, 3), // changes position of shadow
                                ),
                              ],
                            ),
                            child: DropdownButton<String>(
                              underline: Container(
                                height: 1,
                                color: ProjectColor().white,
                              ),
                              alignment: Alignment.center,
                              value: selectedMap,
                              icon: Icon(
                                Icons.arrow_drop_down_rounded,
                                color: ProjectColor().white,
                              ),
                              onChanged: (String? newValue) {
                                if (mounted) {
                                  setState(() {
                                    selectedMap = newValue!;
                                  });
                                }
                              },
                              items: [
                                DropdownMenuItem<String>(
                                  value: 'All',
                                  child: Center(
                                    child: Text(
                                      'MAP',
                                      style: TextStyle(
                                        color: ProjectColor().white,
                                        fontFamily: Fonts().valFonts,
                                      ),
                                    ),
                                  ),
                                ),
                                ...maps.map((map) {
                                  return DropdownMenuItem<String>(
                                    value: map['displayName'],
                                    child: Center(
                                      child: Text(
                                        map['displayName'],
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
                    Container(
                      decoration: BoxDecoration(
                        color: ProjectColor().dark,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: Offset(0, 3), // changes position of shadow
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
                                  offset: Offset(
                                      0, 3), // changes position of shadow
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
                                  ),
                                );
                              }).toList(),
                              dropdownColor: ProjectColor().dark,
                            ),
                          ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: _firestore.collection('lineups').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final lineups = snapshot.data?.docs ?? [];
                final filteredLineups = lineups.where((lineup) {
                  final data = lineup.data() as Map<String, dynamic>;
                  final mapMatches = selectedMap == 'All' ||
                      (data['mapName']?.toString().toLowerCase() ?? '')
                          .contains(selectedMap.toLowerCase());
                  final sideMatches = selectedSide == 'All' ||
                      (data['side']?.toString().toLowerCase() ?? '')
                          .contains(selectedSide.toLowerCase());
                  final agentMatches = selectedAgent == 'All' ||
                      (data['agentName']?.toString().toLowerCase() ?? '')
                          .contains(selectedAgent.toLowerCase());
                  final searchMatches = searchText.isEmpty ||
                      (data['mapName']?.toString().toLowerCase() ?? '')
                          .contains(searchText.toLowerCase()) ||
                      (data['side']?.toString().toLowerCase() ?? '')
                          .contains(searchText.toLowerCase()) ||
                      (data['agentName']?.toString().toLowerCase() ?? '')
                          .contains(searchText.toLowerCase());
                  return mapMatches &&
                      sideMatches &&
                      agentMatches &&
                      searchMatches;
                }).toList();

                return GridView.builder(
                  padding: EdgeInsets.all(8.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: filteredLineups.length,
                  itemBuilder: (context, index) {
                    final lineup = filteredLineups[index];
                    final lineupId = lineup.id;
                    final imagePaths = List<String>.from(lineup['imagePaths']);
                    final lineupData = {
                      'name': lineup['mapName'] ?? 'Unknown',
                      'side': lineup['side'] ?? 'Unknown',
                      'agentName': lineup['agentName'] ?? 'Unknown',
                      'images': imagePaths,
                    };

                    final isSaved = _savedLineups.contains(lineupId);

                    return Card(
                      color: ProjectColor().dark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  LineupDetailScreen(lineup: lineup),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(12.0)),
                                child: Image.network(
                                  imagePaths.isNotEmpty ? imagePaths[0] : '',
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lineup['mapName']
                                            ?.toString()
                                            .toUpperCase() ??
                                        'UNKNOWN',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: ProjectColor().white,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Side: ${lineup['side']?.toString().toUpperCase() ?? 'UNKNOWN'}',
                                    style:
                                        TextStyle(color: ProjectColor().white),
                                  ),
                                  Text(
                                    'Agent: ${lineup['agentName']?.toString().toUpperCase() ?? 'UNKNOWN'}',
                                    style:
                                        TextStyle(color: ProjectColor().white),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  if (_user?.email == 'valineupstr@gmail.com')
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: ProjectColor().white,
                                      ),
                                      onPressed: () => _deleteLineup(
                                          context, lineupId, imagePaths),
                                    ),
                                  IconButton(
                                    icon: Icon(
                                      isSaved
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: ProjectColor().valoRed,
                                    ),
                                    onPressed: () =>
                                        _toggleSaveLineup(lineupId, lineupData),
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
              },
            ),
          ),
        ],
      ),
      floatingActionButton: (_user?.email == 'valineupstr@gmail.com')
          ? FloatingActionButton(
              backgroundColor: ProjectColor().valoRed,
              onPressed: () => _openLineupsHome(context),
              child: Icon(
                Icons.add,
                color: ProjectColor().white,
              ),
            )
          : null,
    );
  }
}
