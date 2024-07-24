import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
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
  String selectedLanguage = 'en-US';

  @override
  void initState() {
    super.initState();
    _loadFavoriteAgent();
    _fetchAgentsFromApi();
  }

  Future<void> _loadFavoriteAgent() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _favoriteAgent = _prefs?.getString('favoriteAgent');
    });
  }

  Future<void> _fetchAgentsFromApi() async {
    final response = await http.get(Uri.parse(
        'https://valorant-api.com/v1/agents?isPlayableCharacter=true&language=$selectedLanguage'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['data'];
      final List<String> agents = [];
      final List<String> agentImages = [];

      for (var agent in data) {
        agents.add(agent['displayName']);
        agentImages.add(agent['bustPortrait']);
      }

      setState(() {
        _agents = agents;
        _agentImages = agentImages;
        if (_favoriteAgent != null) {
          final int favIndex = _agents!.indexOf(_favoriteAgent!);
          if (favIndex != -1) {
            _agents!.removeAt(favIndex);
            _agents!.insert(0, _favoriteAgent!);
            final String favImage = _agentImages!.removeAt(favIndex);
            _agentImages!.insert(0, favImage);
          }
        }
      });
    } else {
      throw Exception('Failed to load agents');
    }
  }

  Future<void> _setFavoriteAgent(String agent) async {
    setState(() {
      _favoriteAgent = agent;
    });
    await _prefs?.setString('favoriteAgent', agent);
    await _loadFavoriteAgent();
  }

  List<String> getDisplayAgents() {
    return _agents ?? [];
  }

  List<String> getDisplayAgentImages() {
    return _agentImages ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final double mediaQueryHeight = MediaQuery.of(context).size.height;

    if (_agents == null || _agentImages == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final List<String> displayAgents = getDisplayAgents();
    final List<String> displayAgentImages = getDisplayAgentImages();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          actions: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownButton<String>(
                underline: Container(
                  height: 2,
                  color: ProjectColor().transparent,
                ),
                value: selectedLanguage,
                dropdownColor: Colors.grey[900], // Dropdown arka plan rengi
                onChanged: (String? newValue) {
                  setState(() {
                    selectedLanguage = newValue!;
                    _fetchAgentsFromApi(); // Dil değiştirildiğinde ajanları tekrar yükle
                  });
                },
                items: <String>['en-US', 'tr-TR']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value == 'en-US' ? 'English' : 'Turkish',
                      style: const TextStyle(
                          color: Colors.white), // Yazı rengi beyaz
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_outlined,
                color: ProjectColor().white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: ProjectColor().dark,
          title: Text(
            'AGENTS',
            style: TextStyle(
              fontFamily: Fonts().valFonts,
              color: ProjectColor().white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
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
                                builder: (context) => AgentDetailPage(
                                  agentName: displayAgents[agentIndex],
                                  agentImage: displayAgentImages[agentIndex],
                                  selectedLanguage:
                                      selectedLanguage, // Language parameter added
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
                                          image: NetworkImage(
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
                                  builder: (context) => AgentDetailPage(
                                    agentName: displayAgents[index],
                                    agentImage: displayAgentImages[index],
                                    selectedLanguage:
                                        selectedLanguage, // Language parameter added
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.network(displayAgentImages[index],
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

class AgentDetailPage extends StatelessWidget {
  final String agentName;
  final String agentImage;
  final String selectedLanguage;

  const AgentDetailPage({
    super.key,
    required this.agentName,
    required this.agentImage,
    required this.selectedLanguage, // Language parameter added
  });

  Future<Map<String, dynamic>> fetchAgentDetails(String agentName) async {
    final response = await http.get(Uri.parse(
        'https://valorant-api.com/v1/agents?isPlayableCharacter=true&language=$selectedLanguage'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      return data.firstWhere((agent) => agent['displayName'] == agentName,
          orElse: () => null);
    } else {
      throw Exception('Failed to load agent details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProjectColor().dark,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_outlined,
              color: ProjectColor().white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: ProjectColor().dark,
        title: Text(
          agentName,
          style: TextStyle(
            fontFamily: Fonts().valFonts,
            color: ProjectColor().white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchAgentDetails(agentName),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          } else {
            final agent = snapshot.data!;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: Image.network(agent['fullPortrait'])),
                    const SizedBox(height: 16),
                    Text(
                      agent['description'],
                      style: TextStyle(
                        fontSize: 16,
                        color: ProjectColor().white.withOpacity(
                              0.7,
                            ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Role: ${agent['role']['displayName']}',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ProjectColor().white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      agent['role']['description'],
                      style: TextStyle(
                        color: ProjectColor().white.withOpacity(
                              0.7,
                            ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Abilities:',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ProjectColor().white),
                    ),
                    ...agent['abilities'].map<Widget>((ability) {
                      return ListTile(
                        leading: Image.network(ability['displayIcon']),
                        title: Text(
                          ability['displayName'],
                          style: TextStyle(
                            color: ProjectColor().white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          ability['description'],
                          style: TextStyle(
                            color: ProjectColor().white.withOpacity(
                                  0.7,
                                ),
                          ),
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
