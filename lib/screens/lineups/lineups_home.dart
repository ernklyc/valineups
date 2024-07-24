import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';
import 'package:valineups/styles/fonts.dart';
import 'package:valineups/styles/project_color.dart';

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
        side.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields and select images.')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final user = _firebaseAuth.currentUser;
    if (user == null || user.email != 'valineupstr@gmail.com') {
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

  void _clearImages() {
    setState(() {
      _images = [];
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
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ||
                        _images.isEmpty ||
                        agentName.isEmpty ||
                        mapName.isEmpty ||
                        side.isEmpty
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
