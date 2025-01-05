import 'package:flutter/material.dart';

class JobRecommendScreen extends StatelessWidget {
  const JobRecommendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JOB RECOMMENDATION'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('Job Recommendation Screen'),
      ),
    );
  }
}