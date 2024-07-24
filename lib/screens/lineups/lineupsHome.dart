import 'dart:io';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';
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
                                setState(() {
                                  selectedMap = newValue!;
                                });
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
                          setState(() {
                            selectedSide = newValue!;
                          });
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
                                setState(() {
                                  selectedAgent = newValue!;
                                });
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
            icon: Icon(Icons.circle, color: ProjectColor().dark),
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
  bool isLoading = false;
  bool isUploading = false;

  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _images = pickedFiles.map((file) => File(file.path)).toList();
        isUploading = true; // Start showing shimmer effect
      });

      // Simulate delay for shimmer effect
      await Future.delayed(Duration(seconds: 2));
      setState(() {
        isUploading = false; // Stop shimmer effect after delay
      });
    }
  }

  Future<void> _uploadImages() async {
    setState(() {
      isLoading = true;
    });

    final user = _firebaseAuth.currentUser;
    if (user == null || user.email != 'ernklyc@gmail.com') {
      return;
    }

    if (_images.isEmpty ||
        agentName.isEmpty ||
        mapName.isEmpty ||
        side.isEmpty) {
      setState(() {
        isLoading = false;
      });
      return;
    }

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
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ProjectColor().dark,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: ProjectColor().dark,
          ),
          onPressed: () {},
        ),
      ),
      backgroundColor: ProjectColor().dark,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildTextField('Ajan Adı', (value) {
                setState(() {
                  agentName = value;
                });
              }),
              SizedBox(height: 10),
              _buildTextField('Harita Adı', (value) {
                setState(() {
                  mapName = value;
                });
              }),
              SizedBox(height: 10),
              _buildTextField('Side Adı (a, b, c)', (value) {
                setState(() {
                  side = value;
                });
              }),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : _pickImages,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isLoading ? Colors.grey : ProjectColor().valoRed,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  minimumSize: Size(double.infinity, 0),
                ),
                child: Text(
                  'PICK PHOTOS',
                  style: TextStyle(
                    fontSize: 16,
                    color: ProjectColor().white,
                    fontFamily: Fonts().valFonts,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              SizedBox(height: 20),
              _images.isEmpty
                  ? Text(
                      'No images selected',
                      style: TextStyle(
                        color: ProjectColor().white.withOpacity(0.5),
                        fontSize: 14,
                      ),
                    )
                  : isUploading
                      ? _buildShimmerEffect()
                      : GridView.builder(
                          shrinkWrap: true,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 4,
                            mainAxisSpacing: 4,
                          ),
                          itemCount: _images.length,
                          itemBuilder: (context, index) {
                            return Image.file(_images[index],
                                fit: BoxFit.cover);
                          },
                        ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : _uploadImages,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isLoading ? Colors.grey : ProjectColor().valoRed,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  minimumSize: Size(double.infinity, 0),
                ),
                child: isLoading
                    ? CircularProgressIndicator(
                        color: ProjectColor().white,
                      )
                    : Text(
                        'UPLOAD LINEUP',
                        style: TextStyle(
                          fontSize: 16,
                          color: ProjectColor().white,
                          fontFamily: Fonts().valFonts,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 150),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ProjectColor().valoRed,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Icon(Icons.cancel, color: ProjectColor().white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String labelText, Function(String) onChanged) {
    return TextField(
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          color: ProjectColor().white.withOpacity(0.5),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: ProjectColor().white,
          ),
        ),
        focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: ProjectColor().white,
          ),
        ),
      ),
      style: TextStyle(
        color: ProjectColor().white,
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildShimmerEffect() {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 0.7,
      ),
      itemCount: 3,
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
