import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LineupListScreen extends StatelessWidget {
  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lineup Listesi'),
      ),
      body: StreamBuilder(
        stream: _firestore.collection('lineups').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final lineups = snapshot.data?.docs ?? [];
          return ListView.builder(
            itemCount: lineups.length,
            itemBuilder: (context, index) {
              final lineup = lineups[index];
              return ListTile(
                title: Text(lineup['agentName']),
                subtitle: Text('${lineup['mapName']} - ${lineup['side']}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LineupDetailScreen(lineup: lineup),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class LineupDetailScreen extends StatelessWidget {
  final DocumentSnapshot lineup;

  LineupDetailScreen({required this.lineup});

  @override
  Widget build(BuildContext context) {
    final imagePaths = List<String>.from(lineup['imagePaths']);
    return Scaffold(
      appBar: AppBar(
        title: Text(lineup['agentName']),
      ),
      body: ListView.builder(
        itemCount: imagePaths.length,
        itemBuilder: (context, index) {
          final imagePath = imagePaths[index];
          return Image.network(imagePath);
        },
      ),
    );
  }
}
