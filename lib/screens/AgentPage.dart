import 'package:flutter/material.dart';
import 'package:valineups/styles/project_color.dart';
import 'package:valineups/utils/constants.dart';

class FullScreenImageViewer extends StatefulWidget {
  final List<String> images;

  const FullScreenImageViewer({Key? key, required this.images})
      : super(key: key);

  @override
  _FullScreenImageViewerState createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  int _currentPage = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              return Center(
                child: Image.asset(
                  widget.images[index],
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Text(
                        'Image not available',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.images.length, (index) {
                return Container(
                  height: 10,
                  width: _currentPage == index ? 12 : 10,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: _currentPage == index ? Colors.white : Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

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

  final List<Map<String, String>> maps = [
    {'name': 'Maps', 'image': ''},
    {'name': 'BIND', 'image': 'assets/images/maps/Bind.png'},
    {'name': 'HAVEN', 'image': 'assets/images/maps/Haven.png'},
    {'name': 'SPLIT', 'image': 'assets/images/maps/Split.png'},
    {'name': 'ASCENT', 'image': 'assets/images/maps/Ascent.png'},
    {'name': 'ICEBOX', 'image': 'assets/images/maps/Icebox.png'},
    {'name': 'BREEZE', 'image': 'assets/images/maps/Breeze.png'},
    {'name': 'FRACTURE', 'image': 'assets/images/maps/Fracture.png'},
    {'name': 'PEARL', 'image': 'assets/images/maps/Pearl.png'},
    {'name': 'LOTUS', 'image': 'assets/images/maps/Lotus.png'},
    {'name': 'SUNSET', 'image': 'assets/images/maps/Sunset.png'},
    {'name': 'Abyss', 'image': 'assets/images/maps/Abyss.png'},
  ];

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
                                      height:
                                          MediaQuery.of(context).size.height,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage(
                                            map['image']!,
                                          ),
                                          fit: BoxFit.fitWidth,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width / 1.1,
                                  height: MediaQuery.of(context).size.height,
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
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  alignment: Alignment.center,
                  icon: const Icon(Icons.arrow_drop_down_rounded),
                  dropdownColor: ProjectColor().dark,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedSide = newValue!;
                    });
                  },
                  items: <String>['Side', 'A', 'B', 'C']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Center(
                        child: Text(
                          value,
                          style: TextStyle(color: ProjectColor().white),
                        ),
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
