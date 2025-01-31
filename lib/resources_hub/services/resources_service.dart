import 'package:codefusion/resources_hub/services/medium_service.dart';
import 'package:codefusion/resources_hub/services/youtube_explode_service.dart';
import 'package:codefusion/resources_hub/services/devto_service.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class ResourcesService {
  final MediumService _mediumService = MediumService();
  final YoutubeExplodeService _youtubeService = YoutubeExplodeService();
  final DevToService _devToService = DevToService();

  Future<Map<String, dynamic>> searchResources(String query) async {
    final articles = await _mediumService.searchArticles(query);
    final videos = await _youtubeService.searchVideos(query);
    final devToArticles = await _devToService.searchArticles(query);

    return {
      'articles': articles,
      'videos': videos,
      'devToArticles': devToArticles,
    };
  }

  Future<List<Video>> searchVideos(String query) async {
    return await _youtubeService.searchVideos(query);
  }
}