import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QAScreen extends StatelessWidget {
  const QAScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Q&A Forum'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('questions').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final questions = snapshot.data!.docs;

          return ListView.builder(
            itemCount: questions.length,
            itemBuilder: (context, index) {
              final question = questions[index];
              return ListTile(
                title: Text(question['title']),
                subtitle: Text(question['tags'].join(', ')),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          QuestionDetailScreen(questionId: question.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PostQuestionScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class PostQuestionScreen extends StatefulWidget {
  @override
  _PostQuestionScreenState createState() => _PostQuestionScreenState();
}

class _PostQuestionScreenState extends State<PostQuestionScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  bool _isPosting = false;

  Future<void> _postQuestion() async {
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _tagsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required.')),
      );
      return;
    }

    setState(() {
      _isPosting = true;
    });

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      final tags = _tagsController.text.split(',').map((tag) => tag.trim()).toList();

      await FirebaseFirestore.instance.collection('questions').add({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'tags': tags,
        'userId': userId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Question posted successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post question: $e')),
      );
    } finally {
      setState(() {
        _isPosting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post a Question')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 4,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _tagsController,
              decoration: const InputDecoration(
                  labelText: 'Tags (comma-separated)'),
            ),
            const SizedBox(height: 16),
            _isPosting
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _postQuestion,
                    child: const Text('Post Question'),
                  ),
          ],
        ),
      ),
    );
  }
}

class QuestionDetailScreen extends StatelessWidget {
  final String questionId;

  const QuestionDetailScreen({Key? key, required this.questionId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Question Details')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('questions')
            .doc(questionId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final question = snapshot.data!;
          final answersStream = FirebaseFirestore.instance
              .collection('answers')
              .where('questionId', isEqualTo: questionId)
              .snapshots();

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
                                  _updateVote(answer.id, 'upvotes');
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.thumb_down),
                                onPressed: () {
                                  _updateVote(answer.id, 'downvotes');
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

  void _updateVote(String answerId, String field) {
    final docRef = FirebaseFirestore.instance.collection('answers').doc(answerId);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) {
        throw Exception("Answer does not exist!");
      }
      final newVotes = (snapshot.data()![field] ?? 0) + 1;
      transaction.update(docRef, {field: newVotes});
    });
  }
}

class PostAnswerScreen extends StatefulWidget {
  final String questionId;

  const PostAnswerScreen({Key? key, required this.questionId})
      : super(key: key);

  @override
  _PostAnswerScreenState createState() => _PostAnswerScreenState();
}

class _PostAnswerScreenState extends State<PostAnswerScreen> {
  final TextEditingController _answerController = TextEditingController();
  bool _isPosting = false;

  Future<void> _postAnswer() async {
    if (_answerController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Answer cannot be empty.')),
      );
      return;
    }

    setState(() {
      _isPosting = true;
    });

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;

      await FirebaseFirestore.instance.collection('answers').add({
        'content': _answerController.text,
        'userId': userId,
        'questionId': widget.questionId,
        'timestamp': FieldValue.serverTimestamp(),
        'upvotes': 0,
        'downvotes': 0,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Answer posted successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post answer: $e')),
      );
    } finally {
      setState(() {
        _isPosting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post an Answer')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _answerController,
              decoration: const InputDecoration(labelText: 'Your Answer'),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            _isPosting
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _postAnswer,
                    child: const Text('Post Answer'),
                  ),
          ],
        ),
      ),
    );
  }
}