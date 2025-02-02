import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:codefusion/Q&A/services/question_service.dart';

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

      await QuestionService().postQuestion(
        _titleController.text,
        _descriptionController.text,
        tags,
        userId!,
      );

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