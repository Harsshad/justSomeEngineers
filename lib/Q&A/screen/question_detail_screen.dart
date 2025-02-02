import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codefusion/Q&A/screen/post_answer_screen.dart';
import 'package:codefusion/Q&A/services/answer_service.dart';
import 'package:codefusion/Q&A/services/question_service.dart';

class QuestionDetailScreen extends StatelessWidget {
  final String questionId;

  const QuestionDetailScreen({Key? key, required this.questionId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final QuestionService questionService = QuestionService();
    final AnswerService answerService = AnswerService();

    return Scaffold(
      appBar: AppBar(title: const Text('Question Details')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: questionService.getQuestionStream(questionId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final question = snapshot.data!;
          final answersStream = answerService.getAnswersStream(questionId);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      question['title'],
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      question['description'],
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tags: ${question['tags'].join(', ')}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: answersStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final answers = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: answers.length,
                      itemBuilder: (context, index) {
                        final answer = answers[index];
                        return ListTile(
                          title: Text(answer['content']),
                          subtitle: Text(
                              'Upvotes: ${answer['upvotes'] ?? 0}, Downvotes: ${answer['downvotes'] ?? 0}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.thumb_up),
                                onPressed: () {
                                  answerService.updateVote(answer.id, 'upvotes');
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.thumb_down),
                                onPressed: () {
                                  answerService.updateVote(answer.id, 'downvotes');
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostAnswerScreen(questionId: questionId),
            ),
          );
        },
        child: const Icon(Icons.add_comment),
      ),
    );
  }
}