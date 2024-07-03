import 'package:flutter/material.dart';
import 'package:valineups/styles/project_color.dart';

class FullScreenImageViewer extends StatelessWidget {
  final List<String> images;

  const FullScreenImageViewer({Key? key, required this.images})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            itemCount: images.length,
            itemBuilder: (context, index) {
              return Center(
                child: Image.asset(
                  images[index],
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
            bottom: 40,
            right: 20,
            child: IconButton(
              icon: Icon(Icons.zoom_out_map, color: Colors.white),
              onPressed: () {
                // Zoom functionality or other actions can be implemented here
              },
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
  String selectedMap = 'All';
  String selectedSide = 'All';

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredMaps = widget.maps.where((map) {
      if (selectedMap != 'All' && map['name'] != selectedMap) {
        return false;
      }
      if (selectedSide != 'All' && map['side'] != selectedSide) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButton<String>(
                value: selectedMap,
                dropdownColor: ProjectColor().dark,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedMap = newValue!;
                  });
                },
                items: <String>['All', 'Bind', 'Haven', 'Split', 'Icebox']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value,
                        style: TextStyle(color: ProjectColor().white)),
                  );
                }).toList(),
              ),
              SizedBox(width: 20),
              DropdownButton<String>(
                value: selectedSide,
                dropdownColor: ProjectColor().dark,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedSide = newValue!;
                  });
                },
                items: <String>['All', 'A', 'B', 'C']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value,
                        style: TextStyle(color: ProjectColor().white)),
                  );
                }).toList(),
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
