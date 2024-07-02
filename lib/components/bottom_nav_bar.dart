import 'package:flutter/material.dart';
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
  int _currentIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (newIndex) {
          setState(() {
            _currentIndex = newIndex;
          });
        },
        children: const [
          Maps(),
          Agents(),
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
            icon: Icon(Icons.map),
            label: "MAPS",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: "AGENTS",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: "CHAT",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "PROFILE",
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
}
