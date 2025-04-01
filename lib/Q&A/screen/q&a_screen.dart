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
    return Scaffold(
      appBar: AppBar(
         leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/main-home',
              (route) => false,
            );

            // Go back to the previous page
          },
        ),
        title:  Text(
          'CodeQuery',
          style: TextStyle(
            fontFamily: 'SourceCodePro',
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        backgroundColor: Colors.blueGrey[900],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: AnimatedSearchBar(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
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
                      color: Colors.blueGrey[100],
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
                            color: Colors.blueGrey[800],
                          ),
                        ),
                        subtitle: Text(
                          question['description'],
                          style: TextStyle(
                            fontFamily: 'SourceCodePro',
                            color: Colors.blueGrey[600],
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.blueGrey[700],
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
              icon: Icon(Icons.send_rounded, color: Colors.blueGrey[500],),
            ),
          ),
        ],
      ),
    );
  }
}