import 'package:flutter/material.dart';
import 'package:valineups/components/valineups_text.dart';
import 'package:valineups/localization/strings.dart';
import 'package:valineups/styles/project_color.dart';
import 'package:valineups/utils/constants.dart';

class Agents extends StatefulWidget {
  const Agents({super.key});

  @override
  State<Agents> createState() => _AgentsState();
}

class _AgentsState extends State<Agents> {
  @override
  Widget build(BuildContext context) {
    final double mediaQueryWidth = MediaQuery.of(context).size.width;
    final double mediaQueryHeight = MediaQuery.of(context).size.height;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: ProjectColor().dark,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              backgroundColor: ProjectColor().dark,
              floating: true,
              snap: true,
              pinned: false,
              flexibleSpace: const FlexibleSpaceBar(
                centerTitle: true,
                title: ValineupsText(),
              ),
            ),
            SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: mediaQueryWidth > 600 ? 3 : 2,
                mainAxisSpacing: 0,
                crossAxisSpacing: 0,
                childAspectRatio: 1,
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return Padding(
                    padding: ProjectEdgeInsets().mapsItem,
                    child: ClipRRect(
                      borderRadius: ProjectBorderRadius().circular12,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: mediaQueryHeight / 2,
                            height: mediaQueryHeight / 2,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(AgentList().agents[index]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Container(
                            width: mediaQueryHeight / 2,
                            height: mediaQueryHeight / 2,
                            color: ProjectColor().dark.withOpacity(0.3),
                          ),
                          Positioned(
                            bottom: 10,
                            left: 10,
                            right: 10,
                            child: Text(
                              AgentList().entries[index],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                shadows: [
                                  Shadow(
                                    color: ProjectColor().dark,
                                    blurRadius: 50,
                                  ),
                                ],
                                color: ProjectColor().white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: AgentList().entries.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
