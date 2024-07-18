import 'package:flutter/material.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  String? _favoriteAgent;
  SharedPreferences? _prefs;
  List<String>? _agents;
  List<String>? _agentImages;

  @override
  void initState() {
    super.initState();
    _loadFavoriteAgent();
  }

  Future<void> _loadFavoriteAgent() async {
    _prefs = await SharedPreferences.getInstance();
    final List<String> agents = AgentList().entries;
    final List<String> agentImages = AgentList().agents;

    setState(() {
      _favoriteAgent = _prefs?.getString('favoriteAgent');
      _agents = agents;
      _agentImages = agentImages;
    });
  }

  Future<void> _setFavoriteAgent(String agent) async {
    setState(() {
      _favoriteAgent = agent;
    });
    await _prefs?.setString('favoriteAgent', agent);
  }

  List<String> getDisplayAgents() {
    if (_favoriteAgent == null) {
      return _agents!;
    }
    final List<String> displayAgents = List.from(_agents!);
    displayAgents.remove(_favoriteAgent);
    displayAgents.insert(0, _favoriteAgent!);
    return displayAgents;
  }

  List<String> getDisplayAgentImages() {
    if (_favoriteAgent == null) {
      return _agentImages!;
    }
    final int favIndex = _agents!.indexOf(_favoriteAgent!);
    final List<String> displayAgentImages = List.from(_agentImages!);
    final String favImage = displayAgentImages.removeAt(favIndex);
    displayAgentImages.insert(0, favImage);
    return displayAgentImages;
  }

  @override
  Widget build(BuildContext context) {
    final double mediaQueryHeight = MediaQuery.of(context).size.height;

    if (_agents == null || _agentImages == null) {
      return CircularProgressIndicator();
    }

    final List<String> displayAgents = getDisplayAgents();
    final List<String> displayAgentImages = getDisplayAgentImages();

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
                    final int agentIndex = index % displayAgents.length;
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
                                  agentName: displayAgents[agentIndex],
                                  agentImage: displayAgentImages[agentIndex],
                                  maps: AgentList()
                                      .agentMaps[displayAgents[agentIndex]]!,
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
                                              displayAgentImages[agentIndex]),
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
                                          displayAgents[agentIndex],
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
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: GestureDetector(
                                    onTap: () async {
                                      await _setFavoriteAgent(
                                          displayAgents[agentIndex]);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              '${displayAgents[agentIndex]} favori olarak kaydedildi!'),
                                        ),
                                      );
                                    },
                                    child: Icon(
                                      _favoriteAgent ==
                                              displayAgents[agentIndex]
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: Colors.yellow,
                                      size: 30.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  itemCount: displayAgents.length,
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
                        itemCount: displayAgents.length,
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
                                    agentName: displayAgents[index],
                                    agentImage: displayAgentImages[index],
                                    maps: AgentList()
                                        .agentMaps[displayAgents[index]]!,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset(displayAgentImages[index],
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
