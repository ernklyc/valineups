import 'package:flutter/material.dart';
import 'package:valineups/components/full_screen_image_viewer.dart';
import 'package:valineups/components/lineups_maps.dart';
import 'package:valineups/components/sides.dart';
import 'package:valineups/styles/project_color.dart';
import 'package:valineups/utils/constants.dart';

class AgentPage extends StatefulWidget {
  final String agentName;
  final String agentImage;
  final List<Map<String, dynamic>> maps;

  const AgentPage({
    Key? key,
    required this.agentName,
    required this.agentImage,
    required this.maps,
  }) : super(key: key);

  @override
  _AgentPageState createState() => _AgentPageState();
}

class _AgentPageState extends State<AgentPage> {
  String selectedMap = 'Maps';
  String selectedSide = 'Side';

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredMaps = widget.maps.where((map) {
      if (selectedMap != 'Maps' && map['name'] != selectedMap) {
        return false;
      }
      if (selectedSide != 'Side' && map['side'] != selectedSide) {
        return false;
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        foregroundColor: ProjectColor().white,
        backgroundColor: ProjectColor().dark,
        title: Text(
          widget.agentName,
          style: TextStyle(
            color: ProjectColor().white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 5,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: ProjectColor().dark,
      body: Column(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: DropdownButton<String>(
                  underline: Container(
                    height: 0,
                  ),
                  value: selectedMap,
                  alignment: Alignment.center,
                  elevation: 10,
                  icon: const Icon(Icons.arrow_drop_down_rounded),
                  dropdownColor: ProjectColor().dark,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedMap = newValue!;
                    });
                  },
                  items: maps.map<DropdownMenuItem<String>>((map) {
                    return DropdownMenuItem<String>(
                      value: map['name']!,
                      child: map['name'] == 'Maps'
                          ? Center(
                              child: Text(
                                map['name']!,
                                style: TextStyle(color: ProjectColor().white),
                              ),
                            )
                          : Stack(
                              alignment: Alignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: ClipRRect(
                                    borderRadius:
                                        ProjectBorderRadius().circular12,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width /
                                          1.1,
                                      height: 150,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage(
                                            map['image']!,
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width / 1.1,
                                  height: 150,
                                  color: ProjectColor().dark.withOpacity(0.5),
                                ),
                                Text(
                                  map['name']!,
                                  style: TextStyle(
                                    shadows: [
                                      Shadow(
                                        color: ProjectColor().white,
                                        blurRadius: 50,
                                      ),
                                    ],
                                    color: ProjectColor().white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 10,
                                  ),
                                ),
                              ],
                            ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(width: 10),
              Center(
                child: DropdownButton<String>(
                  underline: Container(
                    height: 0,
                  ),
                  value: selectedSide,
                  alignment: Alignment.center,
                  elevation: 10,
                  icon: const Icon(Icons.arrow_drop_down_rounded),
                  dropdownColor: ProjectColor().dark,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedSide = newValue!;
                    });
                  },
                  items: sides.map<DropdownMenuItem<String>>((side) {
                    return DropdownMenuItem<String>(
                      value: side['name']!,
                      child: side['name'] == 'Side'
                          ? Center(
                              child: Text(
                                side['name']!,
                                style: TextStyle(color: ProjectColor().white),
                              ),
                            )
                          : Stack(
                              alignment: Alignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: ClipRRect(
                                    borderRadius:
                                        ProjectBorderRadius().circular12,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width /
                                          1.1,
                                      height: 150,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage(
                                            side['image']!,
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width / 1.1,
                                  height: 150,
                                  color: ProjectColor().dark.withOpacity(0.5),
                                ),
                                Text(
                                  side['name']!,
                                  style: TextStyle(
                                    shadows: [
                                      Shadow(
                                        color: ProjectColor().white,
                                        blurRadius: 50,
                                      ),
                                    ],
                                    color: ProjectColor().white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 10,
                                  ),
                                ),
                              ],
                            ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredMaps.length,
              itemBuilder: (context, index) {
                var map = filteredMaps[index];
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
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(12.0)),
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
                              Text(
                                map['name'],
                                style: TextStyle(
                                  color: ProjectColor().white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Side: ${map['side']}",
                                style: TextStyle(
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
            ),
          ),
        ],
      ),
    );
  }
}
