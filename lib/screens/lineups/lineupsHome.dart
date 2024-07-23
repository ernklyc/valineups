import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:valineups/components/full_screen_image_viewer.dart';
import 'package:valineups/screens/home/profile.dart';

class LineupListScreen extends StatefulWidget {
  @override
  State<LineupListScreen> createState() => _LineupListScreenState();
}

class _LineupListScreenState extends State<LineupListScreen> {
  final _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
  }

  Future<void> _deleteLineup(
      BuildContext context, String lineupId, List<String> imagePaths) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null &&
        (user.email == 'ernklyc@gmail.com' ||
            user.email == 'baturaybk@gmail.com' ||
            user.email == 'sevindikemre21@gmail.com')) {
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
        // Firestore'dan belgeyi sil
        await _firestore.collection('lineups').doc(lineupId).delete();

        // Firebase Storage'dan ilgili görselleri sil
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

  Future<void> _saveLineup(Map<String, dynamic> lineup) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final lineupCollection = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('savedLineups');

      // Beğenilen lineup'ı kaydet
      await lineupCollection.add(lineup);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lineup kaydedildi.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kullanıcı oturum açmamış.')),
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

  void _openSavedLineups(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            Profile(), // Open Profile screen to see saved lineups
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('VALineups'),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () => _openSavedLineups(context),
          ),
        ],
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
              final imagePaths = List<String>.from(lineup['imagePaths']);
              final lineupData = {
                'name': lineup['mapName'],
                'side': lineup['side'],
                'agentName': lineup['agentName'],
                'images': imagePaths,
              };

              return Card(
                margin: EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullScreenImageViewer(
                              images: imagePaths,
                            ),
                          ),
                        );
                      },
                      child: Image.network(
                        imagePaths.isNotEmpty ? imagePaths[0] : '',
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
                          Text(
                            lineup['mapName'],
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text('Side: ${lineup['side']}'),
                          Text('Agent: ${lineup['agentName']}'),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (_user?.email == 'ernklyc@gmail.com' ||
                            _user?.email == 'baturaybk@gmail.com' ||
                            _user?.email == 'sevindikemre21@gmail.com')
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () =>
                                _deleteLineup(context, lineup.id, imagePaths),
                          ),
                        IconButton(
                          icon: Icon(Icons.favorite_border),
                          onPressed: () => _saveLineup(lineupData),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: (_user?.email == 'ernklyc@gmail.com' ||
              _user?.email == 'baturaybk@gmail.com' ||
              _user?.email == 'sevindikemre21@gmail.com')
          ? FloatingActionButton(
              onPressed: () => _openLineupsHome(context),
              child: Icon(Icons.add),
            )
          : null,
    );
  }
}

class LineupsHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Your existing LineupsHome code
    return Container();
  }
}
