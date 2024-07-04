import 'package:flutter/material.dart';
import 'package:valineups/components/valineups_text.dart';
import 'package:valineups/localization/strings.dart';
import 'package:valineups/styles/project_color.dart';
import 'package:valineups/utils/constants.dart';

class Maps extends StatefulWidget {
  const Maps({super.key});

  @override
  State<Maps> createState() => _MapsState();
}

class _MapsState extends State<Maps> {
  void _showDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: ProjectColor().transparent,
          contentPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: InteractiveViewer(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                          MapList().mapsWiki[index],
                        ),
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: ProjectColor().valoRed,
                  borderRadius: ProjectBorderRadius().circular12,
                ),
                child: Column(
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Icon(
                        Icons.arrow_back,
                        color: ProjectColor().white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

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
                  return GestureDetector(
                    onTap: () => _showDialog(context, index),
                    child: Padding(
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
