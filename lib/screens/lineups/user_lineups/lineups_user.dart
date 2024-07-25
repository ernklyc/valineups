import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';
import 'package:valineups/styles/fonts.dart';
import 'package:valineups/styles/project_color.dart';

class LineupsUser extends StatefulWidget {
  @override
  _LineupsUserState createState() => _LineupsUserState();
}

class _LineupsUserState extends State<LineupsUser> {
  String email = "";
  List<File> _images = [];
  final _picker = ImagePicker();
  String agentName = '';
  String mapName = '';
  String side = '';
  String senderName = '';
  final _firebaseAuth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  bool isLoading = false;
  bool isUploading = false;
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _checkIfAdmin();
  }

  void _fetchUserData() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        email = user.email ?? "";
      });
    } else {
      if (kDebugMode) {
        print("User is null");
      }
    }
  }

  Future<void> _checkIfAdmin() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        isAdmin = user.email == 'valineupstr@gmail.com';
      });
    }
  }

  Future<void> _pickImages() async {
    if (_images.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You can only upload a maximum of 3 images.')),
      );
      return;
    }

    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _images = pickedFiles
            .map((file) => File(file.path))
            .toList()
            .take(3)
            .toList();
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
    if (_images.isEmpty ||
        agentName.isEmpty ||
        mapName.isEmpty ||
        side.isEmpty ||
        senderName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields and select images.')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final user = _firebaseAuth.currentUser;
    if (user == null || user.email != email) {
      return;
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final pathPrefix = '1_user_lineups/$agentName/$mapName/$side/$timestamp';

    List<String> downloadUrls = [];

    try {
      for (int i = 0; i < _images.length; i++) {
        final ref = _storage.ref().child('$pathPrefix/$i.jpg');
        await ref.putFile(_images[i]);
        final downloadUrl = await ref.getDownloadURL();
        downloadUrls.add(downloadUrl);
      }

      await _firestore.collection('lineups_user').add({
        'userEmail': user.email,
        'agentName': agentName,
        'mapName': mapName,
        'side': side,
        'senderName': senderName,
        'timestamp': timestamp,
        'imagePaths': downloadUrls,
      });

      setState(() {
        _images = [];
        agentName = '';
        mapName = '';
        side = '';
        senderName = '';
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gönderildi, admin onaylaması bekleniyor.')),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gönderme işlemi başarısız: $e')),
      );
    }
  }

  void _clearImages() {
    setState(() {
      _images = [];
    });
  }

  void _showUserImages() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;

    final snapshots = await _firestore
        .collection('lineups_user')
        .where('userEmail', isEqualTo: user.email)
        .get();

    List<String> imageUrls = [];
    for (var doc in snapshots.docs) {
      List<dynamic> urls = doc['imagePaths'];
      imageUrls.addAll(urls.cast<String>());
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Your Uploaded Images'),
          content: Container(
            width: double.maxFinite,
            height: 300,
            child: imageUrls.isEmpty
                ? Center(child: Text('No images found'))
                : ListView.builder(
                    itemCount: imageUrls.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.network(imageUrls[index]),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showAllUserImages() async {
    final snapshots = await _firestore.collection('lineups_user').get();

    List<Map<String, dynamic>> allUserImages = [];
    for (var doc in snapshots.docs) {
      allUserImages.add(doc.data());
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('All Uploaded Images'),
          content: Container(
            width: double.maxFinite,
            height: 300,
            child: allUserImages.isEmpty
                ? Center(child: Text('No images found'))
                : ListView.builder(
                    itemCount: allUserImages.length,
                    itemBuilder: (context, index) {
                      final userImages = allUserImages[index];
                      return ListTile(
                        title: Text(userImages['senderName'] ?? 'Unknown'),
                        subtitle:
                            Text(userImages['agentName'] ?? 'No agent name'),
                        onTap: () {
                          Navigator.of(context).pop();
                          _showImagesDialog(userImages['imagePaths']);
                        },
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showImagesDialog(List<dynamic> imagePaths) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Images'),
          content: Container(
            width: double.maxFinite,
            height: 300,
            child: imagePaths.isEmpty
                ? Center(child: Text('No images found'))
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: imagePaths.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.network(imagePaths[index]),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _firebaseAuth.currentUser;

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
      body: user == null ? _buildNotAuthorizedView() : _buildAuthorizedView(),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: _showAllUserImages,
              backgroundColor: ProjectColor().valoRed,
              child: Icon(Icons.image, color: ProjectColor().white),
            )
          : null,
    );
  }

  Widget _buildNotAuthorizedView() {
    return Center(
      child: Text(
        'You are not authorized to view this page.',
        style: TextStyle(color: ProjectColor().white),
      ),
    );
  }

  Widget _buildAuthorizedView() {
    return SingleChildScrollView(
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
            SizedBox(height: 10),
            _buildTextField('Gönderen Kişi', (value) {
              setState(() {
                senderName = value;
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
            ElevatedButton(
              onPressed: isLoading ||
                      _images.isEmpty ||
                      agentName.isEmpty ||
                      mapName.isEmpty ||
                      side.isEmpty ||
                      senderName.isEmpty
                  ? null
                  : _uploadImages,
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
            SizedBox(height: 20),
            _images.isEmpty
                ? Text(
                    textAlign: TextAlign.center,
                    'No images selected\nMax 3 photos can be uploaded.',
                    style: TextStyle(
                      color: ProjectColor().white.withOpacity(0.5),
                      fontSize: 14,
                    ),
                  )
                : isUploading
                    ? _buildShimmerEffect()
                    : Column(
                        children: [
                          GridView.builder(
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
                          SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: _clearImages,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ProjectColor().valoRed,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              minimumSize: Size(double.infinity, 0),
                            ),
                            child: Text(
                              'CLEAR IMAGES',
                              style: TextStyle(
                                fontSize: 16,
                                color: ProjectColor().white,
                                fontFamily: Fonts().valFonts,
                                fontWeight: FontWeight.w900,
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
