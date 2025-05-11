import 'dart:convert';
import 'dart:io';
import 'package:codefusion/resources_hub/youtube/models/video_model.dart';
import 'package:codefusion/config.dart';
import 'package:http/http.dart' as http;


class APIService {
  APIService._instantiate();

  static final APIService instance = APIService._instantiate();

  final String _baseUrl = 'www.googleapis.com';
  String _nextPageToken = '';

  Future<List<Video>> searchVideos(String query) async {
  Map<String, String> parameters = {
    'part': 'snippet',
    'maxResults': '20',
    'q': query,
    'type': 'video',
    'key': Config.yotubeApiKey,
  };

  Uri uri = Uri.https(_baseUrl, '/youtube/v3/search', parameters);

  Map<String, String> headers = {
    HttpHeaders.contentTypeHeader: 'application/json',
  };

  var response = await http.get(uri, headers: headers);
  if (response.statusCode == 200) {
    List<dynamic> videosJson = json.decode(response.body)['items'];

    List<Video> videos = [];

    for (var json in videosJson) {
      try {
        // Safely check if all required fields are present and not null
        final videoId = json['id']?['videoId'];
        final title = json['snippet']?['title'];
        final thumbnailUrl = json['snippet']?['thumbnails']?['high']?['url'];
        final channelTitle = json['snippet']?['channelTitle'];

        if (videoId != null && title != null && thumbnailUrl != null && channelTitle != null) {
          videos.add(Video(
            id: videoId,
            title: title,
            thumbnailUrl: thumbnailUrl,
            channelTitle: channelTitle,
          ));
        }
      } catch (e) {
        print("Skipping invalid video data: $e");
      }
    }

    return videos;
  } else {
    throw json.decode(response.body)['error']['message'];
  }
}

}