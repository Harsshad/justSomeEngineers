import 'dart:convert';
import 'package:codefusion/config.dart';
import 'package:http/http.dart' as http;

Future<List<dynamic>> fetchArticles(String tag) async {
  String devToapiKey = Config.devToapiKey;
  final url = Uri.parse('https://dev.to/api/articles?tag=$tag&per_page=150');
  
  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Failed to fetch data: ${response.statusCode} ${response.body}');
      return [];
    }
  } catch (e) {
    print('Error: $e');
    return [];
  }
}
