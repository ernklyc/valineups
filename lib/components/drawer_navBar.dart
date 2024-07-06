import 'dart:math';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:valineups/components/valineups_text.dart';
import 'package:valineups/screens/agents.dart';
import 'package:valineups/screens/agent_info.dart';
import 'package:valineups/screens/chat.dart';
import 'package:valineups/screens/level_border.dart';
import 'package:valineups/screens/login_and_guest.dart';
import 'package:valineups/screens/maps.dart';
import 'package:valineups/screens/player_card.dart';
import 'package:valineups/screens/profile.dart';
import 'package:valineups/screens/rank.dart';
import 'package:valineups/screens/sprey.dart';
import 'package:valineups/screens/wapon.dart';
import 'package:valineups/screens/wapon_skins.dart';
import 'package:valineups/styles/project_color.dart';

class ControlPage extends StatefulWidget {
  const ControlPage({super.key});

  @override
  _ControlPageState createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  int _currentIndex = 0;
  int _selectedIndex = 0;

  final PageController _pageController = PageController(initialPage: 0);

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String generateGuestUserName(int length) {
    final random = Random();
    final int maxRandomValue = pow(10, length).toInt() - 1;
    final int randomNumber = random.nextInt(maxRandomValue);
    return 'guest${randomNumber.toString().padLeft(length, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    String guestUserName = generateGuestUserName(6);

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu,
                  color: ProjectColor().white), // Drawer icon color is set here
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
        backgroundColor: ProjectColor().dark,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipOval(
                    child: RandomAvatar(
                      DateTime.now().toIso8601String(),
                      height: 70,
                      width: 70,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    guestUserName,
                    style: TextStyle(
                      color: ProjectColor().white,
                      fontSize: 16,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            _createDrawerItem(
              icon: FontAwesomeIcons.userAlt,
              text: 'Agents Info',
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AgentsList()));
              },
            ),
            _createDrawerItem(
              icon: FontAwesomeIcons.rankingStar,
              text: 'Rank Tiers',
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CompetitiveTiersScreen()));
              },
            ),
            _createDrawerItem(
              icon: FontAwesomeIcons.borderStyle,
              text: 'Level Borders',
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LevelBorderListScreen()));
              },
            ),
            _createDrawerItem(
              icon: FontAwesomeIcons.idCard,
              text: 'Player Cards',
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PlayerCardsScreen()));
              },
            ),
            _createDrawerItem(
              icon: FontAwesomeIcons.sprayCan,
              text: 'Sprays',
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SprayListScreen()));
              },
            ),
            _createDrawerItem(
              icon: FontAwesomeIcons.gun,
              text: 'Weapon',
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const WeaponsPage()));
              },
            ),
            _createDrawerItem(
              icon: FontAwesomeIcons.gun,
              text: 'Weapon Skins',
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => WeaponSkinsScreen()));
              },
            ),
            _createDrawerItem(
              icon: Icons.logout,
              text: 'Logout',
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginAndGuestScreen()));
              },
            ),
          ],
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (newIndex) {
          setState(() {
            _currentIndex = newIndex;
          });
        },
        children: const [
          Agents(),
          Maps(),
          Chat(),
          Profile(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: ProjectColor().dark,
        selectedItemColor: ProjectColor().white,
        unselectedItemColor: ProjectColor().hintGrey,
        unselectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
        selectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: "AGENTS",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: "MAPS",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: "CHAT",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: "SAVED",
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 500),
              curve: Curves.ease,
            );
          });
        },
      ),
    );
  }

  Widget _createDrawerItem(
      {required IconData icon,
      required String text,
      required GestureTapCallback onTap}) {
    return ListTile(
      leading: FaIcon(
        icon,
        color: ProjectColor().white,
      ),
      title: Text(
        text,
        style: TextStyle(
          color: ProjectColor().white,
        ),
      ),
      onTap: onTap,
    );
  }
}
