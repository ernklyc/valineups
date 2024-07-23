import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:valineups/components/full_screen_image_viewer.dart';
import 'package:valineups/styles/fonts.dart';
import 'package:valineups/styles/project_color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Widget svgCode =
      RandomAvatar('saytoonz', trBackground: true, height: 50, width: 50);
  List<Map<String, dynamic>> savedMaps = [];

  @override
  void initState() {
    super.initState();
    _loadSavedLineups();
  }

  Future<void> _loadSavedLineups() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final lineupCollection = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('savedLineups');

      final querySnapshot = await lineupCollection.get();
      setState(() {
        savedMaps = querySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    }
  }

  Future<void> _saveLineup(Map<String, dynamic> lineup) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final lineupCollection = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('savedLineups');

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

  Future<void> _removeMap(Map<String, dynamic> map) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final lineupCollection = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('savedLineups');

      final querySnapshot =
          await lineupCollection.where('name', isEqualTo: map['name']).get();
      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }

      setState(() {
        savedMaps.remove(map);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProjectColor().dark,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 32.0,
                    bottom: 16.0,
                  ),
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
              ],
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                var map = savedMaps[index];
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12.0)),
                          child: Image.network(
                            map['images'][0],
                            fit: BoxFit.fitWidth,
                            width: double.infinity,
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
                                      fontFamily: Fonts().valFonts,
                                      color: ProjectColor().white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
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
                              const SizedBox(height: 4),
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
              childCount: savedMaps.length,
            ),
          ),
        ],
      ),
    );
  }
}
