import 'package:flutter/material.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:valineups/localization/strings.dart';
import 'package:valineups/screens/AgentPage.dart';
import 'package:valineups/styles/fonts.dart';
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
    final double mediaQueryHeight = MediaQuery.of(context).size.height;
    final List<String> agents = AgentList().entries;
    final List<String> agentImages = AgentList().agents;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: ProjectColor().dark,
        body: Center(
          child: SizedBox(
            height: mediaQueryHeight * 0.65,
            child: Swiper(
              loop: true,
              viewportFraction: 0.8,
              scale: 0.9,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                final int agentIndex = index % agents.length;
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: ProjectBorderRadius().circular30,
                      color: ProjectColor().valoRed,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AgentPage(
                              agentName: agents[agentIndex],
                              agentImage: agentImages[agentIndex],
                              maps: AgentList().agentMaps[agents[agentIndex]]!,
                            ),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: ProjectBorderRadius().circular12,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Stack(
                              children: [
                                Container(
                                  width: mediaQueryHeight * 0.4,
                                  height: mediaQueryHeight * 0.6,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(
                                        agentImages[agentIndex],
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 10, top: 20),
                                  child: RotatedBox(
                                    quarterTurns: 3,
                                    child: Text(
                                      agents[agentIndex],
                                      style: TextStyle(
                                        fontFamily: Fonts().valFonts,
                                        shadows: [
                                          Shadow(
                                            color: ProjectColor().dark,
                                            blurRadius: 60,
                                          ),
                                        ],
                                        color: ProjectColor().white,
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
              itemCount: 24,
            ),
          ),
        ),
      ),
    );
  }
}
