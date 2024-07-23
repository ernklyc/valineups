import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class LineupListScreen extends StatelessWidget {
  final _firestore = FirebaseFirestore.instance;

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
      appBar: AppBar(
        title: Text('Lineup Listesi'),
      ),
      body: StreamBuilder(
        stream: _firestore.collection('lineups').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final lineups = snapshot.data?.docs ?? [];
          return ListView.builder(
            itemCount: lineups.length,
            itemBuilder: (context, index) {
              final lineup = lineups[index];
              return ListTile(
                title: Text(lineup['agentName']),
                subtitle: Text('${lineup['mapName']} - ${lineup['side']}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LineupDetailScreen(lineup: lineup),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openLineupsHome(context),
        child: Icon(Icons.add),
      ),
    );
  }
}

class LineupDetailScreen extends StatelessWidget {
  final DocumentSnapshot lineup;

  LineupDetailScreen({required this.lineup});

  @override
  Widget build(BuildContext context) {
    final imagePaths = List<String>.from(lineup['imagePaths']);
    return Scaffold(
      appBar: AppBar(
        title: Text(lineup['agentName']),
      ),
      body: ListView.builder(
        itemCount: imagePaths.length,
        itemBuilder: (context, index) {
          final imagePath = imagePaths[index];
          return Image.network(imagePath);
        },
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
    if (_images.isEmpty || agentName.isEmpty || mapName.isEmpty || side.isEmpty)
      return;

    final user = _firebaseAuth.currentUser;
    if (user == null) return;

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
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Ajan Adı'),
                onChanged: (value) {
                  setState(() {
                    agentName = value;
                  });
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Harita Adı'),
                onChanged: (value) {
                  setState(() {
                    mapName = value;
                  });
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Side Adı (a, b, c)'),
                onChanged: (value) {
                  setState(() {
                    side = value;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImages,
                child: Text('Fotoğraf Seç'),
              ),
              SizedBox(height: 20),
              _images.isEmpty
                  ? Text('Hiç fotoğraf seçilmedi.')
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
                child: Text('Fotoğrafları Yükle'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
