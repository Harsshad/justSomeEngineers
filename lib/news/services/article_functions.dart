import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<dynamic>> fetchArticles(String tag) async {
  String apiKey = 'iZL3dE1c6w58BimpGP86fP84';
  final url = Uri.parse('https://dev.to/api/articles?tag=$tag&per_page=70');
  
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
