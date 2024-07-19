import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:valineups/styles/fonts.dart';
import 'dart:convert';

import 'package:valineups/styles/project_color.dart';

class PlayerCardsScreen extends StatefulWidget {
  const PlayerCardsScreen({super.key});

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
          'PLAYER CARDS',
          style: TextStyle(
            fontFamily: Fonts().valFonts,
            color: ProjectColor().white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1600 / 2560,
              ),
              itemCount: playerCards.length,
              itemBuilder: (context, index) {
                final card = playerCards[index];
                String displayName = card['displayName'];
                if (displayName.length > 5) {
                  displayName = '${displayName.substring(0, 10)}...';
                }
                return Card(
                  elevation: 0,
                  color: ProjectColor().dark,
                  clipBehavior: Clip.antiAlias, // Clip the overflowing content
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Image.network(
                            card['largeArt'],
                            fit: BoxFit
                                .contain, // Resmin kartın içine sığmasını sağla
                          ),
                        ),
                      ),
                      Text(
                        displayName,
                        style: TextStyle(
                          fontFamily: Fonts().valFonts,
                          color: ProjectColor().white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
