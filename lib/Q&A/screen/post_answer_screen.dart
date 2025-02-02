import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:codefusion/Q&A/services/answer_service.dart';

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
        const SnackBar(
          content: Text(
            'Answer cannot be empty.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isPosting = true;
    });

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;

      await AnswerService().postAnswer(
        _answerController.text,
        userId!,
        widget.questionId,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Answer posted successfully!',
          ),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to post answer: $e',
          ),
        ),
      );
    } finally {
      setState(
        () {
          _isPosting = false;
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Post an Answer',
        ),
      ),
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
                    child: const Text(
                      'Post Answer',
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
