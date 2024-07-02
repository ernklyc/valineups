// AgentList.dart
import 'package:flutter/material.dart';

class AgentList extends StatelessWidget {
  final int mapIndex;
  final String side;

  // Example lists for demonstration
  static List<String> agents = [
    'agent1.png',
    'agent2.png',
    'agent3.png',
  ];

  static List<String> entries = [
    'Agent 1',
    'Agent 2',
    'Agent 3',
  ];

  const AgentList({super.key, required this.mapIndex, required this.side});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agent List'),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 0,
          crossAxisSpacing: 0,
          childAspectRatio: 1,
        ),
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              // Handle tapping on an agent
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Image.asset(
                    agents[index], // Use the agents list here
                    width: MediaQuery.of(context).size.width / 3,
                    height: MediaQuery.of(context).size.width / 3,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    entries[index], // Use the entries list here
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        itemCount: agents.length, // Use the length of agents or entries
      ),
    );
  }
}
