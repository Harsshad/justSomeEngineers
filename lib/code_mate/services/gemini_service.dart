import 'package:flutter_gemini/flutter_gemini.dart';

class BotGeminiService {
  final String apiKey;

  BotGeminiService(this.apiKey) {
    Gemini.init(apiKey: apiKey, enableDebugging: true);
  }

  Future<String> getResponse(String query) async {
    const String codeFusionInfo = """
    CodeFusion is an all-in-one developer-centric platform designed to integrate mentorship, career growth, community discussions, and collaborative tools. Here are its key modules:
    
    1) **Home**: Displays 7 recently added mentors and latest live news from Dev.to.
    2) **Profile**: Shows user/mentor details with an edit profile option for users.
    3) **CodeMate**: An AI chatbot (this bot) powered by Gemini API for coding-related queries.
    4) **CodeQuery**: A Q&A forum where users/mentors post, answer, and upvote/downvote questions.
    5) **FusionMeet**: Video conferencing powered by Jitsi Meet (available on mobile).
    6) **Dev Guru**: A mentorship system where users can apply to mentors, and mentors can manage mentees.
    7) **Resources**: Offers learning materials—articles (Medium & Dev.to), videos (YouTube), and step-by-step roadmaps.
    8) **DevChat**: Real-time chat for users and mentors, with reporting and blocking options.
    9) **Resume Gen**: Automatically generates a resume based on user inputs.
    10) **Job Board**: Fetches real-time job listings from LinkedIn API with search functionality.
    11) **Settings**: Includes dark mode and blocked user management.
    12) **Logout**: Allows users to log out and log in anytime.
    
    CodeFusion aims to unify mentorship, job opportunities, and collaborative coding under one platform, making it unique from platforms like LinkedIn or Stack Overflow.
    """;

    final response = await Gemini.instance.prompt(parts: [
      Part.text("""
      You are CodeMate, an AI assistant for the CodeFusion platform. Your primary role is to help users with coding-related questions. However, if a user asks about CodeFusion, its features, or its modules, provide the following accurate information:
      $codeFusionInfo
      
      If the question is unrelated to CodeFusion, answer normally as a coding assistant.
      """),
      Part.text(query),
    ]);

    if (response != null && response.output != null) {
      return response.output!;
    } else {
      throw Exception('Failed to fetch response');
    }
  }
}
