import 'dart:ui';

import 'package:codefusion/global_resources/components/animated_shadow_button.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codefusion/Q&A/services/question_service.dart';
import 'package:codefusion/Q&A/screen/question_detail_screen.dart';
import 'package:codefusion/Q&A/screen/post_question_screen.dart';
import 'package:codefusion/global_resources/components/animated_search_bar.dart'; // Import the animated search bar

class QAScreen extends StatefulWidget {
  @override
  _QAScreenState createState() => _QAScreenState();
}

class _QAScreenState extends State<QAScreen> {
  final QuestionService questionService = QuestionService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

 @override
Widget build(BuildContext context) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: isDarkMode
            ? [Colors.black87, Colors.blueGrey.shade900] // Dark mode gradient
            : [const Color(0xFFDFD7C2), const Color(0xFFF7DB4C)], // Light mode gradient
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: Scaffold(
      backgroundColor: Colors.transparent, // Transparent to show gradient
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Transparent AppBar
        elevation: 0, // No elevation for a clean look
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode ? Colors.white : const Color(0xFF2A2824),
          ),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/main-home',
              (route) => false,
            );
          },
        ),
        title: Text(
          'CodeQuery',
          style: TextStyle(
            fontFamily: 'SourceCodePro',
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: isDarkMode ? Colors.white : const Color(0xFF2A2824),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: AnimatedSearchBar(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
        ],
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12), // Blur effect
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDarkMode
                      ? [Colors.black87, Colors.blueGrey.shade900] // Dark mode gradient
                      : [const Color(0xFFDFD7C2), const Color(0xFFF7DB4C)], // Light mode gradient
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: FractionallySizedBox(
          widthFactor: 0.9, // Limit the width to 90% of the screen
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: questionService.getQuestionsStream(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final questions = snapshot.data!.docs.where((question) {
                      final data = question.data() as Map<String, dynamic>;
                      final title = data['title'] as String;
                      final description = data['description'] as String;
                      final tags = data['tags'] as List<dynamic>;
                      return title.contains(_searchQuery) ||
                          description.contains(_searchQuery) ||
                          tags.any((tag) => tag.contains(_searchQuery));
                    }).toList();

                    return ListView.builder(
                      itemCount: questions.length,
                      itemBuilder: (context, index) {
                        final question = questions[index];
                        return Card(
                          color: isDarkMode ? Colors.blueGrey[800] : Colors.blueGrey[100],
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: Text(
                              question['title'],
                              style: TextStyle(
                                fontFamily: 'SourceCodePro',
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : Colors.blueGrey[800],
                              ),
                            ),
                            subtitle: Text(
                              question['description'],
                              style: TextStyle(
                                fontFamily: 'SourceCodePro',
                                color: isDarkMode ? Colors.white70 : Colors.blueGrey[600],
                              ),
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              color: isDarkMode ? Colors.white70 : Colors.blueGrey[700],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => QuestionDetailScreen(
                                    questionId: question.id,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: AnimatedShadowButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PostQuestionScreen()),
                    );
                  },
                  text: 'Post Question',
                  icon: Icon(
                    Icons.send_rounded,
                    color: isDarkMode ? Colors.white70 : Colors.blueGrey[500],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}