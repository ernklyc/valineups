import 'package:flutter/material.dart';
import 'package:valineups/styles/project_color.dart';

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
              Container(
                alignment: Alignment.center,
                width: 100,
                height: 50,
                color: ProjectColor().white,
                child: DropdownButton<String>(
                  value: selectedMap,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedMap = newValue!;
                    });
                  },
                  items: <String>['All', 'Bind', 'Haven', 'Split', 'Icebox']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(
                          color: ProjectColor().dark,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              Container(
                alignment: Alignment.center,
                width: 100,
                height: 50,
                color: ProjectColor().white,
                child: DropdownButton<String>(
                  value: selectedSide,
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
                          style: TextStyle(color: ProjectColor().dark)),
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
                          images: map['images'],
                        ),
                      ),
                    );
                  },
                  child: Card(
                    child: Column(
                      children: [
                        Text(map['name']),
                        Text(map['side']),
                        Image.asset(map['images'][0]),
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
              return Image.asset(images[index]);
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
        ],
      ),
    );
  }
}
