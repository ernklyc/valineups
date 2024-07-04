import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:valineups/components/full_screen_image_viewer.dart';
import 'package:valineups/components/valineups_text.dart';
import 'package:valineups/screens/login_and_guest.dart';
import 'package:valineups/styles/project_color.dart';

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

  Future<void> _removeMap(Map<String, dynamic> map) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      savedMaps.removeWhere((savedMap) => savedMap['name'] == map['name']);
    });
    await prefs.setString('savedMaps', json.encode(savedMaps));
  }

  String generateGuestUserName(int length) {
    final random = Random();
    final int maxRandomValue = pow(10, length).toInt() - 1;
    final int randomNumber = random.nextInt(maxRandomValue);
    return 'guest${randomNumber.toString().padLeft(length, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // Örneğin, 8 haneli bir kullanıcı adı oluşturmak için:
    String guestUserName = generateGuestUserName(6);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: ProjectColor().dark,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              backgroundColor: ProjectColor().dark,
              floating: true,
              snap: true,
              pinned: false,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: FaIcon(
                      // ignore: deprecated_member_use
                      FontAwesomeIcons.earth,
                      color: ProjectColor().white,
                      size: 20,
                    ),
                  ),
                  const ValineupsText(),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginAndGuestScreen(),
                        ),
                      );
                    },
                    icon: FaIcon(
                      // ignore: deprecated_member_use
                      FontAwesomeIcons.signOutAlt,
                      color: ProjectColor().white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  ClipOval(
                    child: RandomAvatar(
                      DateTime.now().toIso8601String(),
                      height: 70,
                      width: 70,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    guestUserName,
                    style: TextStyle(
                        color: ProjectColor().white,
                        fontSize: 16,
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Divider(
                    color: ProjectColor().white.withOpacity(0.2),
                    thickness: 2,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "SAVED LINEUPS",
                    style: TextStyle(
                      color: ProjectColor().white,
                      fontSize: 20,
                      letterSpacing: 5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
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
                      margin: EdgeInsets.all(8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      color: ProjectColor().dark.withOpacity(0.8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(
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
                                        Icons.remove_circle_outline,
                                        color: ProjectColor().white,
                                      ),
                                      onPressed: () {
                                        _removeMap(map);
                                      },
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Side: ${map['side']}",
                                  style: TextStyle(
                                    color:
                                        ProjectColor().white.withOpacity(0.7),
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
      ),
    );
  }
}
