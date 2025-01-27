import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

class MediumService {
  static const String _baseUrl = 'https://medium.com/feed/tag';

  Future<List<Article>> searchArticles(String query) async {
    final encodedQuery = Uri.encodeComponent(query);
    final response = await http.get(
      Uri.parse('$_baseUrl/$encodedQuery'),
    );

    if (response.statusCode == 200) {
      final document = xml.XmlDocument.parse(response.body);
      final items = document.findAllElements('item');
      return items.map((item) => Article.fromXml(item)).toList();
    } else {
      throw Exception('Failed to load articles');
    }
  }
}

class Article {
  final String title;
  final String description;
  final String link;
  final String pubDate;

  Article({
    required this.title,
    required this.description,
    required this.link,
    required this.pubDate,
  });

  factory Article.fromXml(xml.XmlElement element) {
    return Article(
      title: element.findElements('title').single.text,
      description: element.findElements('description').single.text,
      link: element.findElements('link').single.text,
      pubDate: element.findElements('pubDate').single.text,
    );
  }
}