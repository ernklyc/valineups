import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shimmer/shimmer.dart';
import 'package:valineups/styles/project_color.dart';

class AgentsList extends StatefulWidget {
  @override
  _AgentsListState createState() => _AgentsListState();
}

class _AgentsListState extends State<AgentsList> {
  List<dynamic> agents = [];

  @override
  void initState() {
    super.initState();
    fetchAgents();
  }

  Future<void> fetchAgents() async {
    final response =
        await http.get(Uri.parse('https://valorant-api.com/v1/agents'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        agents = data['data']
            .where((agent) => agent['isPlayableCharacter'] == true)
            .toList();
      });
    } else {
      throw Exception('Ajanlar yüklenemedi');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProjectColor().dark,
      appBar: AppBar(
        leading: IconButton(
          icon:
              Icon(Icons.keyboard_backspace_sharp, color: ProjectColor().white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: ProjectColor().dark,
        title: Text(
          'VALORANT AGENTS INFO',
          style: TextStyle(
            color: ProjectColor().white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: agents.isEmpty
          ? Shimmer.fromColors(
              baseColor: Colors.grey.shade800,
              highlightColor: Colors.grey.shade600,
              enabled: true,
              child: ListView.builder(
                itemCount: 6,
                itemBuilder: (_, __) => Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 48.0,
                        height: 48.0,
                        color: Colors.white,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: double.infinity,
                              height: 8.0,
                              color: Colors.white,
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 2.0),
                            ),
                            Container(
                              width: double.infinity,
                              height: 8.0,
                              color: Colors.white,
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 2.0),
                            ),
                            Container(
                              width: 40.0,
                              height: 8.0,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          : ListView.builder(
              itemCount: agents.length,
              itemBuilder: (context, index) {
                final agent = agents[index];
                return Card(
                  color: ProjectColor().dark,
                  child: ListTile(
                    leading: Image.network(agent['displayIcon']),
                    title: Text(
                      agent['displayName'],
                      style: TextStyle(
                        color: ProjectColor().white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      agent['description'],
                      style: TextStyle(
                        color: ProjectColor().white.withOpacity(0.5),
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward,
                      color: ProjectColor().white,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AgentDetail(agent: agent),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

class AgentDetail extends StatefulWidget {
  final dynamic agent;

  AgentDetail({required this.agent});

  @override
  _AgentDetailState createState() => _AgentDetailState();
}

class _AgentDetailState extends State<AgentDetail> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAgentDetails();
  }

  Future<void> _loadAgentDetails() async {
    await Future.delayed(Duration(seconds: 2)); // Simulate network delay
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProjectColor().dark,
      appBar: AppBar(
        leading: IconButton(
          icon:
              Icon(Icons.keyboard_backspace_sharp, color: ProjectColor().white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: ProjectColor().dark,
        title: Text(
          widget.agent['displayName'],
          style: TextStyle(
            color: ProjectColor().white,
          ),
        ),
      ),
      body: _loading
          ? Shimmer.fromColors(
              baseColor: Colors.grey.shade800,
              highlightColor: Colors.grey.shade600,
              enabled: true,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 300,
                        height: 300,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Container(
                      width: 200,
                      height: 24.0,
                      color: Colors.white,
                    ),
                    SizedBox(height: 8.0),
                    Container(
                      width: double.infinity,
                      height: 16.0,
                      color: Colors.white,
                    ),
                    SizedBox(height: 16.0),
                    Container(
                      width: 100,
                      height: 20.0,
                      color: Colors.white,
                    ),
                    SizedBox(height: 8.0),
                    Expanded(
                      child: ListView.builder(
                        itemCount: 4,
                        itemBuilder: (_, __) => Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: Row(
                            children: [
                              Container(
                                width: 48.0,
                                height: 48.0,
                                color: Colors.white,
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      width: double.infinity,
                                      height: 8.0,
                                      color: Colors.white,
                                    ),
                                    const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 2.0),
                                    ),
                                    Container(
                                      width: double.infinity,
                                      height: 8.0,
                                      color: Colors.white,
                                    ),
                                    const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 2.0),
                                    ),
                                    Container(
                                      width: 40.0,
                                      height: 8.0,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Image.network(widget.agent['fullPortrait'])),
                  SizedBox(height: 16.0),
                  Text(
                    widget.agent['displayName'],
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: ProjectColor().white,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    widget.agent['description'],
                    style: TextStyle(
                      fontSize: 16,
                      color: ProjectColor().white.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Yetenekler:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: ProjectColor().white,
                    ),
                  ),
                  ...widget.agent['abilities'].map<Widget>((ability) {
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
                          color: ProjectColor().white.withOpacity(0.7),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
    );
  }
}
