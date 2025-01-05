import 'package:flutter/material.dart';

class ResourcesScreen extends StatelessWidget {
  const ResourcesScreen({super.key});

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