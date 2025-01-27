import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YoutubeExplodeService {
  final YoutubeExplode _ytExplode = YoutubeExplode();

  Future<List<Video>> searchVideos(String query) async {
    final searchResults = await _ytExplode.search.search(query);
    return searchResults.toList();
  }

  void dispose() {
    _ytExplode.close();
  }
}