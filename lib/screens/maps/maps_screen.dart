// main.dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:valineups/screens/maps/maps_api.dart';
import 'package:valineups/screens/maps/maps_model.dart';
import 'package:valineups/styles/fonts.dart';
import 'package:valineups/styles/project_color.dart';

class MapListScreen extends StatefulWidget {
  const MapListScreen({super.key});

  @override
  _MapListScreenState createState() => _MapListScreenState();
}

class _MapListScreenState extends State<MapListScreen> {
  late Future<List<MapModel>> futureMaps;

  @override
  void initState() {
    super.initState();
    futureMaps = ApiService().fetchMaps();
  }

  void _showDialog(BuildContext context, MapModel map) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
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
                        image: NetworkImage(map.displayIcon),
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: ProjectColor().valoRed,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
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

  Widget _buildShimmerEffect() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 4.5,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          );
        },
        childCount: 10,
      ),
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
            FutureBuilder<List<MapModel>>(
              future: futureMaps,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildShimmerEffect();
                } else if (snapshot.hasError) {
                  return SliverFillRemaining(
                    child: Center(child: Text('Error: ${snapshot.error}')),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(child: Text('No maps found')),
                  );
                } else {
                  List<MapModel> maps = snapshot.data!;
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () => _showDialog(context, maps[index]),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: mediaQueryWidth,
                                    height: mediaQueryHeight / 4.5,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: NetworkImage(
                                          maps[index].splash,
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: mediaQueryWidth,
                                    height: mediaQueryHeight / 4.5,
                                    decoration: BoxDecoration(
                                      color:
                                          ProjectColor().dark.withOpacity(0.5),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 130,
                                    left: 20,
                                    child: Text(
                                      maps[index].displayName,
                                      style: TextStyle(
                                        fontFamily: Fonts().valFonts,
                                        shadows: [
                                          Shadow(
                                            color: ProjectColor().dark,
                                            blurRadius: 0,
                                          ),
                                        ],
                                        color: ProjectColor().white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 3,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 110,
                                    left: 23,
                                    child: Text(
                                      maps[index].tacticalDescription,
                                      style: TextStyle(
                                        fontFamily: Fonts().valFonts,
                                        shadows: [
                                          Shadow(
                                            color: ProjectColor().dark,
                                            blurRadius: 0,
                                          ),
                                        ],
                                        color: ProjectColor().white,
                                        fontSize: 16,
                                        letterSpacing: 1,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: maps.length,
                    ),
                  );
                }
              },
            ),
            SliverToBoxAdapter(
              child: Container(
                height: 60,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MapDetailScreen extends StatelessWidget {
  final MapModel map;

  MapDetailScreen({required this.map});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(map.displayName),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(map.displayIcon),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Geri Dön'),
            ),
          ],
        ),
      ),
    );
  }
}
