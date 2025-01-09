import 'package:flutter/material.dart';

import 'resume_display_page.dart';

class ResumeInputPage extends StatefulWidget {
  const ResumeInputPage({Key? key}) : super(key: key);

  @override
  State<ResumeInputPage> createState() => _ResumeInputPageState();
}

class _ResumeInputPageState extends State<ResumeInputPage> {
  // Controllers for user input
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController currentPositionController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController educationController = TextEditingController();

  // Variables to hold input data dynamically
  String fullName = '';
  String currentPosition = '';
  String bio = '';
  List<String> experiences = [];
  List<String> educationDetails = [];

  // Method to display the data
  void submitData() {
    setState(() {
      fullName = fullNameController.text;
      currentPosition = currentPositionController.text;
      bio = bioController.text;
      experiences = experienceController.text.split('\n');
      educationDetails = educationController.text.split('\n');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resume Generator'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          TextField(
            controller: fullNameController,
            decoration: const InputDecoration(labelText: 'Full Name'),
          ),
          TextField(
            controller: currentPositionController,
            decoration: const InputDecoration(labelText: 'Current Position'),
          ),
          TextField(
            controller: bioController,
            decoration: const InputDecoration(labelText: 'Bio'),
            maxLines: 3,
          ),
          TextField(
            controller: experienceController,
            decoration: const InputDecoration(
              labelText: 'Experience (Enter each role on a new line)',
            ),
            maxLines: 5,
          ),
          TextField(
            controller: educationController,
            decoration: const InputDecoration(
              labelText: 'Education (Enter each detail on a new line)',
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: submitData,
            child: const Text('Submit'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ResumeDisplayPage(
                    fullName: fullName,
                    currentPosition: currentPosition,
                    bio: bio,
                    experiences: experiences,
                    educationDetails: educationDetails,
                  ),
                ),
              );
            },
            child: const Text('View Resume'),
          ),
        ],
      ),
    );
  }
}
