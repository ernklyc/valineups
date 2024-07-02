import 'package:flutter/material.dart';
import 'package:valineups/components/valineups_text.dart';
import 'package:valineups/localization/strings.dart';
import 'package:valineups/styles/project_color.dart';
import 'package:valineups/utils/constants.dart';

class Maps extends StatelessWidget {
  const Maps({super.key});

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
            SliverList(
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
                            width: mediaQueryWidth,
                            height: mediaQueryHeight / 10,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(MapList().map[index]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Container(
                            width: mediaQueryWidth,
                            height: mediaQueryHeight / 10,
                            color: ProjectColor().dark.withOpacity(0.5),
                          ),
                          Text(
                            MapList().entries[index],
                            style: TextStyle(
                              shadows: [
                                Shadow(
                                  color: ProjectColor().dark,
                                  blurRadius: 50,
                                ),
                              ],
                              color: ProjectColor().white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: MapList().entries.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
