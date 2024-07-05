import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Valorant Player Cards',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PlayerCardsScreen(),
    );
  }
}

class PlayerCardsScreen extends StatefulWidget {
  @override
  _PlayerCardsScreenState createState() => _PlayerCardsScreenState();
}

class _PlayerCardsScreenState extends State<PlayerCardsScreen> {
  List<dynamic> playerCards = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPlayerCards();
  }

  Future<void> fetchPlayerCards() async {
    final response =
        await http.get(Uri.parse('https://valorant-api.com/v1/playercards'));
    if (response.statusCode == 200) {
      setState(() {
        playerCards = json.decode(response.body)['data'];
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load player cards');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Valorant Player Cards'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1080 / 1920,
              ),
              itemCount: playerCards.length,
              itemBuilder: (context, index) {
                final card = playerCards[index];
                return Card(
                  clipBehavior: Clip.antiAlias, // Clip the overflowing content
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Image.network(
                          card['largeArt'],
                          fit: BoxFit.contain,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          card['displayName'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
