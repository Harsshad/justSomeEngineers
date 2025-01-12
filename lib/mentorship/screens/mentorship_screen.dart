import 'package:flutter/material.dart';

class MentorshipScreen extends StatelessWidget {
  const MentorshipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mentorship'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('Mentorship Screen'),
      ),
    );
  }
}