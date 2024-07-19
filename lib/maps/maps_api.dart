// api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:valineups/maps/maps_model.dart';

class ApiService {
  final String apiUrl = 'https://valorant-api.com/v1/maps';

  Future<List<MapModel>> fetchMaps() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body)['data'];
      List<MapModel> maps =
          body.map((dynamic item) => MapModel.fromJson(item)).toList();
      await _downloadImages(maps);
      return maps;
    } else {
      throw Exception('Failed to load maps');
    }
  }

  Future<void> _downloadImages(List<MapModel> maps) async {
    final dio = Dio();
    final dir = await getApplicationDocumentsDirectory();
    final imageDir = Directory('${dir.path}/images');
    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }

    for (var map in maps) {
      final imageUrl = map.splash;
      final fileName = path.basename(imageUrl);
      final filePath = '${imageDir.path}/$fileName';

      if (!File(filePath).existsSync()) {
        final response = await dio.download(imageUrl, filePath);
        if (response.statusCode == 200) {
          map.localSplashPath = filePath;
        }
      } else {
        map.localSplashPath = filePath;
      }
    }
  }
}
