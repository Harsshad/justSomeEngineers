import "package:flutter/material.dart";

class ResumeDisplayPage extends StatelessWidget {
  final String fullName;
  final String currentPosition;
  final String bio;
  final List<String> experiences;
  final List<String> educationDetails;

  const ResumeDisplayPage({
    Key? key,
    required this.fullName,
    required this.currentPosition,
    required this.bio,
    required this.experiences,
    required this.educationDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Resume'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              fullName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              currentPosition,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            const Text(
              'Bio:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(bio),
            const SizedBox(height: 16),
            const Text(
              'Experience:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            for (var experience in experiences)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text('- $experience'),
              ),
            const SizedBox(height: 16),
            const Text(
              'Education:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            for (var education in educationDetails)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text('- $education'),
              ),
          ],
        ),
      ),
    );
  }
}
