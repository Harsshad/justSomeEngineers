import 'package:flutter_gemini/flutter_gemini.dart';

class BotGeminiService {
  final String apiKey;

  BotGeminiService(this.apiKey) {
    Gemini.init(apiKey: apiKey, enableDebugging: true);
  }

  Future<String> getResponse(String query) async {
    final response = await Gemini.instance.prompt(parts: [
      Part.text(query),
    ]);

    if (response != null && response.output != null) {
      return response.output!;
    } else {
      throw Exception('Failed to fetch response');
    }
  }
}