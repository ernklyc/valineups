import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:valineups/styles/fonts.dart';
import 'dart:convert';

import 'package:valineups/styles/project_color.dart';

class AgentsInfo extends StatefulWidget {
  @override
  _AgentsInfoState createState() => _AgentsInfoState();
}

class _AgentsInfoState extends State<AgentsInfo> {
  String selectedLanguage = 'en-US';

  Future<List<dynamic>> fetchAgents(String language) async {
    final response = await http.get(
        Uri.parse('https://valorant-api.com/v1/agents?language=$language'));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      return data['data'];
    } else {
      throw Exception('Failed to load agents');
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
          'AGENTS INFO',
          style: TextStyle(
            fontFamily: Fonts().valFonts,
            color: ProjectColor().white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButton<String>(
              value: selectedLanguage,
              dropdownColor: Colors.grey[900], // Dropdown'un arka plan rengi
              onChanged: (String? newValue) {
                setState(() {
                  selectedLanguage = newValue!;
                });
              },
              items: <String>['en-US', 'tr-TR']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value == 'en-US' ? 'English' : 'Turkish',
                    style: TextStyle(color: Colors.white), // Yazı rengi beyaz
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: fetchAgents(selectedLanguage),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No data available'));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var agent = snapshot.data![index];
                      if (agent['displayName'] == 'Sova') {
                        return Container(); // "Sova" karakterini göstermeyin
                      }
                      return Card(
                        color: ProjectColor().valoRed,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        margin:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 16),
                          child: ListTile(
                            leading: Image.network(
                              agent['displayIcon'],
                            ),
                            title: Text(
                              agent['displayName'].toUpperCase(),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: Fonts().valFonts,
                              ),
                            ),
                            subtitle: Text(
                              agent['description'],
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AgentDetailPage(agent: agent),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AgentDetailPage extends StatelessWidget {
  final Map<String, dynamic> agent;

  AgentDetailPage({required this.agent});

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
          agent['displayName'],
          style: TextStyle(
            fontFamily: Fonts().valFonts,
            color: ProjectColor().white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Image.network(agent['fullPortrait'])),
              SizedBox(height: 16),
              Text(
                agent['description'],
                style: TextStyle(
                  fontSize: 16,
                  color: ProjectColor().white.withOpacity(
                        0.7,
                      ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Role: ${agent['role']['displayName']}',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ProjectColor().white),
              ),
              SizedBox(height: 8),
              Text(
                agent['role']['description'],
                style: TextStyle(
                  color: ProjectColor().white.withOpacity(
                        0.7,
                      ),
                ),
              ),
              SizedBox(height: 16),
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
              SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
