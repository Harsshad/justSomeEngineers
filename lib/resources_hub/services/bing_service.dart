import 'dart:convert';
import 'package:http/http.dart' as http;

class BingService {
  static const String _apiKey = 'YOUR_BING_API_KEY';
  static const String _baseUrl = 'https://api.bing.microsoft.com/v7.0/search';

  Future<List<WebResult>> searchWeb(String query) async {
    final response = await http.get(
      Uri.parse('$_baseUrl?q=$query'),
      headers: {
        'Ocp-Apim-Subscription-Key': _apiKey,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List webPages = data['webPages']['value'];
      return webPages.map((page) => WebResult.fromJson(page)).toList();
    } else {
      throw Exception('Failed to load web results');
    }
  }
}

class WebResult {
  final String name;
  final String snippet;
  final String url;

  WebResult({
    required this.name,
    required this.snippet,
    required this.url,
  });

  factory WebResult.fromJson(Map<String, dynamic> json) {
    return WebResult(
      name: json['name'],
      snippet: json['snippet'],
      url: json['url'],
    );
  }
}