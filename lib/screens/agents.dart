import 'package:flutter/material.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:valineups/localization/strings.dart';
import 'package:valineups/screens/AgentPage.dart';
import 'package:valineups/styles/fonts.dart';
import 'package:valineups/styles/project_color.dart';
import 'package:valineups/utils/constants.dart';

class Agents extends StatefulWidget {
  const Agents({super.key});

  @override
  State<Agents> createState() => _AgentsState();
}

class _AgentsState extends State<Agents> {
  bool _isDropdownOpen = false;

  @override
  Widget build(BuildContext context) {
    final double mediaQueryHeight = MediaQuery.of(context).size.height;
    final List<String> agents = AgentList().entries;
    final List<String> agentImages = AgentList().agents;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: ProjectColor().dark,
        body: Stack(
          children: [
            Center(
              child: SizedBox(
                height: mediaQueryHeight * 0.8,
                child: Swiper(
                  loop: true,
                  viewportFraction: 0.8,
                  scale: 0.9,
                  scrollDirection: Axis.vertical,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    final int agentIndex = index % agents.length;
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: ProjectBorderRadius().circular30,
                          color: ProjectColor().valoRed,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AgentPage(
                                  agentName: agents[agentIndex],
                                  agentImage: agentImages[agentIndex],
                                  maps: AgentList()
                                      .agentMaps[agents[agentIndex]]!,
                                ),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: ProjectBorderRadius().circular12,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Stack(
                                  children: [
                                    Container(
                                      width: mediaQueryHeight * 0.4,
                                      height: mediaQueryHeight * 0.6,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage(
                                              agentImages[agentIndex]),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10, top: 20),
                                      child: RotatedBox(
                                        quarterTurns: 3,
                                        child: Text(
                                          agents[agentIndex],
                                          style: TextStyle(
                                            fontFamily: Fonts().valFonts,
                                            shadows: [
                                              Shadow(
                                                color: ProjectColor().dark,
                                                blurRadius: 60,
                                              ),
                                            ],
                                            color: ProjectColor().white,
                                            fontSize: 48,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  itemCount: 24,
                ),
              ),
            ),
            _isDropdownOpen
                ? Positioned(
                    bottom: 130.0,
                    right: 16.0,
                    child: Container(
                      height: mediaQueryHeight * 0.6,
                      width: 100.0,
                      decoration: BoxDecoration(
                        color: ProjectColor()
                            .white
                            .withOpacity(0.8), // Dark background color
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: ListView.builder(
                        itemCount: agents.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _isDropdownOpen = false;
                              });
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AgentPage(
                                    agentName: agents[index],
                                    agentImage: agentImages[index],
                                    maps: AgentList().agentMaps[agents[index]]!,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset(agentImages[index],
                                  height: 90.0, width: 90.0),
                            ),
                          );
                        },
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              _isDropdownOpen = !_isDropdownOpen;
            });
          },
          backgroundColor: ProjectColor().white,
          child: FaIcon(
            FontAwesomeIcons.userNinja,
            color: ProjectColor().valoRed,
          ),
        ),
      ),
    );
  }
}
