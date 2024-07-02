import 'package:flutter/material.dart';
import 'package:valineups/components/custom_text.dart';
import 'package:valineups/localization/strings.dart';
import 'package:valineups/styles/project_color.dart';

class Maps extends StatefulWidget {
  const Maps({super.key});

  @override
  State<Maps> createState() => _MapsState();
}

class _MapsState extends State<Maps> {
  final List<String> entries = <String>[
    'BIND',
    'HAVEN',
    'SPLIT',
    'ASCENT',
    'ICEBOX',
    'BREEZE',
    'FRACTURE',
    'PEARL',
    'LOTUS',
    'SUNSET',
    'ABYSS',
  ];

  final List<String> map = <String>[
    'assets/images/maps/Bind.png',
    'assets/images/maps/Haven.png',
    'assets/images/maps/Split.png',
    'assets/images/maps/Ascent.png',
    'assets/images/maps/Icebox.png',
    'assets/images/maps/Breeze.png',
    'assets/images/maps/Fracture.png',
    'assets/images/maps/Pearl.png',
    'assets/images/maps/Lotus.png',
    'assets/images/maps/Sunset.png',
    'assets/images/maps/Abyss.png',
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: ProjectColor().dark,
        body: CustomScrollView(
          physics: BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              backgroundColor: ProjectColor().dark,
              floating: true,
              snap: true,
              pinned: false,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomText(
                      txt: AuthPageText().va,
                      txtColor: ProjectColor().customWhite,
                    ),
                    CustomText(
                      txt: AuthPageText().l,
                      txtColor: ProjectColor().valoRed,
                    ),
                    CustomText(
                      txt: AuthPageText().ineups,
                      txtColor: ProjectColor().customWhite,
                    ),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height / 10,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(map[index]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height / 10,
                            color: ProjectColor().dark.withOpacity(0.5),
                          ),
                          Text(
                            entries[index],
                            style: const TextStyle(
                              shadows: [
                                Shadow(
                                  color: Colors.black,
                                  blurRadius: 50,
                                ),
                              ],
                              color: Colors.white,
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
                childCount: entries.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
