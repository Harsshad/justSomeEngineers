import 'package:flutter_gemini/flutter_gemini.dart';

class GeminiService {
  final String apiKey;

  GeminiService(this.apiKey) {
    Gemini.init(apiKey: apiKey, enableDebugging: true);
  }

  Future<String> getRoadmap(String query) async {
    final response = await Gemini.instance.prompt(parts: [
      Part.text('Provide a detailed roadmap for $query. (add spacing between the heading and the content also if possible make the heading bold)'),
    ]);

    if (response != null && response.output!=null) {
      return response.output!;
    } else {
      throw Exception('Failed to fetch roadmap');
    }
  }
}
