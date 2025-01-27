import 'dart:convert';
import 'package:http/http.dart' as http;

class DevToService {
  static const String _baseUrl = 'https://dev.to/api/articles';

  Future<List<DevToArticle>> searchArticles(String query) async {
    final url = '$_baseUrl?tag=$query';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => DevToArticle.fromJson(json)).toList();
    } else {
      print('Error fetching articles from Dev.to: ${response.statusCode}');
      throw Exception('Failed to load articles');
    }
  }
}

class DevToArticle {
  final String title;
  final String description;
  final String url;

  DevToArticle({
    required this.title,
    required this.description,
    required this.url,
  });

  factory DevToArticle.fromJson(Map<String, dynamic> json) {
    return DevToArticle(
      title: json['title'],
      description: json['description'],
      url: json['url'],
    );
  }
}