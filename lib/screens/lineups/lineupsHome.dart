import 'dart:io';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:valineups/components/sides.dart';
import 'package:valineups/styles/fonts.dart';
import 'package:valineups/styles/project_color.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:valineups/utils/constants.dart';

class LineupListScreen extends StatefulWidget {
  @override
  State<LineupListScreen> createState() => _LineupListScreenState();
}

class _LineupListScreenState extends State<LineupListScreen> {
  final _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  Set<String> _savedLineups = Set<String>();

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
      setState(() {
        maps = data['data'];
        isLoadingMaps = false;
      });
    } else {
      throw Exception('Failed to load maps');
    }
  }

  Future<void> _fetchAgents() async {
    final response = await http.get(Uri.parse(
        'https://valorant-api.com/v1/agents?isPlayableCharacter=true'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      setState(() {
        agents = ['All'];
        for (var agent in data) {
          agents.add(agent['displayName']);
        }
        isLoadingAgents = false;
      });
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
        SnackBar(content: Text('Lineup kaydedildi.')),
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
    if (user != null && user.email == 'ernklyc@gmail.com') {
      final confirmation = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Silmek istediğinize emin misiniz?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Hayır'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Evet'),
              ),
            ],
          );
        },
      );

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProjectColor().dark,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                isLoadingMaps
                    ? Center(child: CircularProgressIndicator())
                    : DropdownButton<String>(
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
                        items: ['All', ...maps.map((map) => map['displayName'])]
                            .map<DropdownMenuItem<String>>((map) {
                          return DropdownMenuItem<String>(
                            value: map,
                            child: map == 'All'
                                ? Center(
                                    child: Text(
                                      map,
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
                                                2,
                                            height: 150,
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: NetworkImage(
                                                    maps.firstWhere((element) =>
                                                        element[
                                                            'displayName'] ==
                                                        map)['splash']),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                2,
                                        height: 150,
                                        color: ProjectColor()
                                            .dark
                                            .withOpacity(0.5),
                                      ),
                                      Text(
                                        map,
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
                    items: ['All', ...sides.map((side) => side['name'])]
                        .map<DropdownMenuItem<String>>((side) {
                      return DropdownMenuItem<String>(
                        value: side,
                        child: Center(
                          child: Text(
                            side!,
                            style: TextStyle(
                              color: ProjectColor().white,
                              fontFamily: Fonts().valFonts,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 10),
                isLoadingAgents
                    ? Center(child: CircularProgressIndicator())
                    : Center(
                        child: DropdownButton<String>(
                          underline: Container(
                            height: 0,
                          ),
                          value: selectedAgent,
                          alignment: Alignment.center,
                          elevation: 10,
                          icon: const Icon(Icons.arrow_drop_down_rounded),
                          dropdownColor: ProjectColor().dark,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedAgent = newValue!;
                            });
                          },
                          items: agents.map<DropdownMenuItem<String>>((agent) {
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
                        ),
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
                      data['mapName']
                          .toString()
                          .toLowerCase()
                          .contains(selectedMap.toLowerCase());
                  final sideMatches = selectedSide == 'All' ||
                      data['side']
                          .toString()
                          .toLowerCase()
                          .contains(selectedSide.toLowerCase());
                  final agentMatches = selectedAgent == 'All' ||
                      data['agentName']
                          .toString()
                          .toLowerCase()
                          .contains(selectedAgent.toLowerCase());
                  return mapMatches && sideMatches && agentMatches;
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
                      'name': lineup['mapName'],
                      'side': lineup['side'],
                      'agentName': lineup['agentName'],
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
                                    lineup['mapName'].toString().toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: ProjectColor().white,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Side: ${lineup['side'].toString().toUpperCase()}',
                                    style:
                                        TextStyle(color: ProjectColor().white),
                                  ),
                                  Text(
                                    'Agent: ${lineup['agentName'].toString().toUpperCase()}',
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
                                  if (_user?.email == 'ernklyc@gmail.com' ||
                                      _user?.email == 'baturaybk@gmail.com' ||
                                      _user?.email ==
                                          'sevindikemre21@gmail.com')
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: ProjectColor().valoRed,
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
      floatingActionButton: (_user?.email == 'ernklyc@gmail.com' ||
              _user?.email == 'baturaybk@gmail.com' ||
              _user?.email == 'sevindikemre21@gmail.com')
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

class LineupDetailScreen extends StatefulWidget {
  final DocumentSnapshot lineup;

  LineupDetailScreen({required this.lineup});

  @override
  _LineupDetailScreenState createState() => _LineupDetailScreenState();
}

class _LineupDetailScreenState extends State<LineupDetailScreen> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final imagePaths = List<String>.from(widget.lineup['imagePaths']);
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.photo, color: ProjectColor().white),
            onPressed: () {},
          ),
        ],
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ProjectColor().white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              widget.lineup['mapName'].toString().toUpperCase(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ProjectColor().white,
              ),
            ),
            Text(
              "|",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ProjectColor().white,
              ),
            ),
            Text(
              widget.lineup['side'].toString().toUpperCase(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ProjectColor().white,
              ),
            ),
            Text(
              "|",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ProjectColor().white,
              ),
            ),
            Text(
              widget.lineup['agentName'].toString().toUpperCase(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ProjectColor().white,
              ),
            ),
          ],
        ),
        backgroundColor: ProjectColor().dark,
      ),
      backgroundColor: ProjectColor().dark,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                CarouselSlider(
                  options: CarouselOptions(
                    height: 400.0,
                    viewportFraction: 1.0,
                    enlargeCenterPage: false,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                  ),
                  items: imagePaths.map((imagePath) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          width: MediaQuery.of(context).size.width / 2,
                          margin: EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            image: DecorationImage(
                              image: NetworkImage(imagePath),
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
                SizedBox(height: 10),
                Center(
                  child: AnimatedSmoothIndicator(
                    activeIndex: _currentImageIndex,
                    count: imagePaths.length,
                    effect: ScrollingDotsEffect(
                      activeDotColor: ProjectColor().white,
                      dotColor: ProjectColor().white.withOpacity(0.5),
                      dotHeight: 8.0,
                      dotWidth: 8.0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class LineupsHome extends StatefulWidget {
  @override
  _LineupsHomeState createState() => _LineupsHomeState();
}

class _LineupsHomeState extends State<LineupsHome> {
  List<File> _images = [];
  final _picker = ImagePicker();
  String agentName = '';
  String mapName = '';
  String side = '';
  final _firebaseAuth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _images = pickedFiles.map((file) => File(file.path)).toList();
      });
    }
  }

  Future<void> _uploadImages() async {
    final user = _firebaseAuth.currentUser;
    if (user == null || user.email != 'ernklyc@gmail.com') {
      return;
    }

    if (_images.isEmpty || agentName.isEmpty || mapName.isEmpty || side.isEmpty)
      return;

    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final pathPrefix = '/$agentName/$mapName/$side/$timestamp';

    List<String> downloadUrls = [];

    for (int i = 0; i < _images.length; i++) {
      final ref = _storage.ref().child('$pathPrefix/$i.jpg');
      await ref.putFile(_images[i]);
      final downloadUrl = await ref.getDownloadURL();
      downloadUrls.add(downloadUrl);
    }

    await _firestore.collection('lineups').add({
      'userEmail': user.email,
      'agentName': agentName,
      'mapName': mapName,
      'side': side,
      'timestamp': timestamp,
      'imagePaths': downloadUrls,
    });

    setState(() {
      _images = [];
      agentName = '';
      mapName = '';
      side = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Valorant Uygulaması'),
        backgroundColor: ProjectColor().dark,
      ),
      backgroundColor: ProjectColor().dark,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Ajan Adı',
                  labelStyle: TextStyle(color: ProjectColor().white),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: ProjectColor().white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: ProjectColor().valoRed),
                  ),
                ),
                style: TextStyle(color: ProjectColor().white),
                onChanged: (value) {
                  setState(() {
                    agentName = value;
                  });
                },
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Harita Adı',
                  labelStyle: TextStyle(color: ProjectColor().white),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: ProjectColor().white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: ProjectColor().valoRed),
                  ),
                ),
                style: TextStyle(color: ProjectColor().white),
                onChanged: (value) {
                  setState(() {
                    mapName = value;
                  });
                },
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Side Adı (a, b, c)',
                  labelStyle: TextStyle(color: ProjectColor().white),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: ProjectColor().white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: ProjectColor().valoRed),
                  ),
                ),
                style: TextStyle(color: ProjectColor().white),
                onChanged: (value) {
                  setState(() {
                    side = value;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImages,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ProjectColor().valoRed,
                ),
                child: Text('Fotoğraf Seç'),
              ),
              SizedBox(height: 20),
              _images.isEmpty
                  ? Text('Hiç fotoğraf seçilmedi.',
                      style: TextStyle(color: ProjectColor().white))
                  : GridView.builder(
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 4,
                      ),
                      itemCount: _images.length,
                      itemBuilder: (context, index) {
                        return Image.file(_images[index], fit: BoxFit.cover);
                      },
                    ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _uploadImages,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ProjectColor().valoRed,
                ),
                child: Text('Fotoğrafları Yükle'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
