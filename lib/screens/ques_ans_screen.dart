import 'package:flutter/material.dart';

class QuesAnsScreen extends StatelessWidget {
  const QuesAnsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ques & Ans'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('Ques & Ans Screen'),
      ),
    );
  }
}