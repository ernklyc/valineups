import 'dart:math';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:valineups/components/valineups_text.dart';
import 'package:valineups/screens/agents.dart';
import 'package:valineups/screens/agents_info.dart';
import 'package:valineups/screens/bundles.dart';
import 'package:valineups/screens/chat.dart';
import 'package:valineups/screens/login_and_guest.dart';
import 'package:valineups/screens/maps.dart';
import 'package:valineups/screens/news.dart';
import 'package:valineups/screens/player_card.dart';
import 'package:valineups/screens/profile.dart';
import 'package:valineups/screens/rank.dart';
import 'package:valineups/screens/sprey.dart';
import 'package:valineups/screens/wapon.dart';
import 'package:valineups/screens/wapon_skins.dart';
import 'package:valineups/styles/fonts.dart';
import 'package:valineups/styles/project_color.dart';
import 'package:valineups/services/firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ControlPage extends StatefulWidget {
  const ControlPage({super.key});

  @override
  _ControlPageState createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  int _currentIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);
  final AuthService authService = AuthService();
  String guestUserName = "";
  String displayName = "";
  String email = "";
  String photoUrl = "";

  @override
  void initState() {
    super.initState();
    authService.signInWithGoogle().then((_) {
      setState(() {
        displayName = authService.displayName ?? generateGuestUserName(6);
        email = authService.email ?? 'valineups user';
        photoUrl = authService.photoUrl ?? "";
      });
    });
    guestUserName = shortenName(generateGuestUserName(6), 30);
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  String generateGuestUserName(int length) {
    final random = Random();
    final int maxRandomValue = pow(10, length).toInt() - 1;
    final int randomNumber = random.nextInt(maxRandomValue);
    return 'guest${randomNumber.toString().padLeft(length, '0')}';
  }

  String shortenName(String name, int maxLength) {
    if (name.length > maxLength) {
      return '${name.substring(0, maxLength - 3)}...';
    }
    return name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProjectColor().dark,
      appBar: AppBar(
        elevation: 0,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu, color: ProjectColor().white),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications,
              color: ProjectColor().white,
            ),
            onPressed: () {},
          ),
        ],
        backgroundColor: ProjectColor().dark,
        title: const ValineupsText(),
      ),
      drawer: Drawer(
        elevation: 0,
        backgroundColor: ProjectColor().dark,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.width * 0.15,
                horizontal: MediaQuery.of(context).size.width * 0.05,
              ),
              child: Row(
                children: [
                  ClipOval(
                    child: photoUrl.isNotEmpty
                        ? Image.network(photoUrl, height: 50, width: 50)
                        : RandomAvatar(
                            DateTime.now().toIso8601String(),
                            height: 50,
                            width: 50,
                          ),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        displayName,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: ProjectColor().white,
                          fontSize: 13,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        email,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: ProjectColor().hintGrey,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _createDrawerItem(
                    text: 'A G E N T S',
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AgentsInfo()));
                    },
                    iconDrawerr: const FaIcon(
                      FontAwesomeIcons.userNinja,
                      size: 16,
                    ),
                  ),
                  _createDrawerItem(
                    text: 'T I E R S',
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const CompetitiveTiersScreen()));
                    },
                    iconDrawerr: const FaIcon(
                      FontAwesomeIcons.trophy,
                      size: 16,
                    ),
                  ),
                  _createDrawerItem(
                    text: 'W E A P O N S',
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const WeaponsPage()));
                    },
                    iconDrawerr: const FaIcon(
                      FontAwesomeIcons.gun,
                      size: 16,
                    ),
                  ),
                  _createDrawerItem(
                    text: 'S K I N S',
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const WeaponSkinsScreen()));
                    },
                    iconDrawerr: const FaIcon(
                      FontAwesomeIcons.sackDollar,
                      size: 16,
                    ),
                  ),
                  _createDrawerItem(
                    text: 'B U N D L E S',
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const BundlesPage()));
                    },
                    iconDrawerr: const FaIcon(
                      FontAwesomeIcons.boxArchive,
                      size: 16,
                    ),
                  ),
                  _createDrawerItem(
                    text: 'C A R D S',
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PlayerCardsScreen()));
                    },
                    iconDrawerr: const FaIcon(
                      FontAwesomeIcons.clipboardUser,
                      size: 16,
                    ),
                  ),
                  _createDrawerItem(
                    text: 'S P R A Y S',
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SprayListScreen()));
                    },
                    iconDrawerr: const FaIcon(
                      FontAwesomeIcons.sprayCanSparkles,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.1,
                  left: 12,
                  right: 12),
              child: _createDrawerItem(
                text: 'L O G O U T',
                onTap: () async {
                  await authService.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginAndGuestScreen(),
                    ),
                  );
                },
                iconDrawerr: const FaIcon(
                  FontAwesomeIcons.outdent,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            height: 80,
            color: ProjectColor().dark,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTopNavigationItem(Icons.people, "AGENTS", 0),
                _buildTopNavigationItem(Icons.map, "MAPS", 1),
                _buildTopNavigationItem(Icons.bookmark, "SAVED", 2),
                _buildTopNavigationItem(Icons.chat, "CHAT", 3),
                _buildTopNavigationItem(Icons.chat, "NEWS", 4),
              ],
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (newIndex) {
                setState(() {
                  _currentIndex = newIndex;
                });
              },
              children: const [
                Agents(),
                Maps(),
                Profile(),
                Chat(),
                News(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _createDrawerItem({
    required String text,
    required FaIcon iconDrawerr,
    required GestureTapCallback onTap,
  }) {
    text = shortenName(text, 30);
    return ListTile(
      leading: iconDrawerr,
      iconColor: ProjectColor().white,
      title: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: ProjectColor().dark,
              blurRadius: 0,
            ),
          ],
          color: ProjectColor().white,
          fontSize: 17,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildTopNavigationItem(IconData icon, String label, int index) {
    label = shortenName(label, 30);
    return GestureDetector(
      onTap: () {
        _onItemTapped(index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 25),
          Text(
            label,
            style: TextStyle(
              fontFamily: Fonts().valFonts,
              color: _currentIndex == index
                  ? ProjectColor().white
                  : ProjectColor().hintGrey,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          if (_currentIndex == index)
            Container(
              margin: const EdgeInsets.only(top: 2),
              height: 2,
              width: 20,
              color: ProjectColor().valoRed,
            ),
        ],
      ),
    );
  }
}
