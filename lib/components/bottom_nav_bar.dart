import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:valineups/screens/agents.dart';
import 'package:valineups/screens/chat.dart';
import 'package:valineups/screens/maps.dart';
import 'package:valineups/screens/profile.dart';
import 'package:valineups/styles/project_color.dart';

class PageControl extends StatefulWidget {
  const PageControl({super.key});

  @override
  State<PageControl> createState() => _PageControlState();
}

class _PageControlState extends State<PageControl> {
  int _selectedIndex = 0;
  bool isAnonymous = false;

  @override
  void initState() {
    super.initState();
    _checkAnonymousStatus();
  }

  Future<void> _checkAnonymousStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isAnonymous = prefs.getBool('isAnonymous') ?? false;
    });
  }

  void _onItemTapped(int index) {
    if (isAnonymous && index == 1) {
      // Anonim kullanıcı chat sayfasına erişemez
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Anonim kullanıcılar chat sayfasını kullanamaz.')),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  static const List<Widget> _widgetOptions = <Widget>[
    Agents(),
    Maps(),
    Chat(),
    Profile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Control'),
        backgroundColor: ProjectColor().dark,
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Agents',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Maps',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: ProjectColor().valoRed,
        onTap: _onItemTapped,
      ),
    );
  }
}
