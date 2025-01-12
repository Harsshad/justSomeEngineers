import 'package:flutter/material.dart';
import 'package:flutter_resume_template/flutter_resume_template.dart';

class ResumeDisplayPage extends StatelessWidget {
  final String fullName;
  final String currentPosition;
  final String bio;
  final String address;
  final List<String> experiences;
  final List<String> educationDetails;
  final List<String> languages;
  final List<String> hobbies;
  final String email;
  final String profileImageUrl;

  const ResumeDisplayPage({
    Key? key,
    required this.fullName,
    required this.currentPosition,
    required this.bio,
    required this.address,
    required this.experiences,
    required this.educationDetails,
    required this.languages,
    required this.hobbies,
    required this.email,
    required this.profileImageUrl,
  }) : super(key: key);

  Future<void> downloadResume(
      GlobalKey<State<StatefulWidget>> globalKey, BuildContext context) async {
    try {
      // Call the `PdfHandler` to create the resume PDF
      await PdfHandler().createResume(globalKey);

      // If successful, show success toast message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Resume downloaded successfully.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // If failed, show error toast message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Resume not downloaded successfully. Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = TemplateData(
      fullName: fullName,
      currentPosition: currentPosition,
      address: address,
      bio: bio,
      experience: experiences
          .map((e) => ExperienceData(
                experienceTitle: e,
                experienceLocation: '',
                experiencePeriod: '',
                experiencePlace: '',
                experienceDescription: e,
              ))
          .toList(),
      educationDetails: educationDetails.map((e) => Education(e, '')).toList(),
      languages: languages.map((e) => Language(e, 3)).toList(),
      hobbies: hobbies,
      email: email,
      image: profileImageUrl, // Ensure profileImageUrl is passed correctly
      // image: 'https://www.dreamstime.com/illustration/default-user.html', // like this image uri
    );

    final GlobalKey<State<StatefulWidget>> globalKey = GlobalKey();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Resume'),
      ),
      body: FlutterResumeTemplate(
        key: globalKey,
        data: data,
        templateTheme: TemplateTheme.classic,
        mode: TemplateMode.shakeEditAndSaveMode,
        onSaveResume: (key) async {
          await downloadResume(key, context);
          return key;
        },
        enableDivider: true,
        showButtons: true,
        backgroundColor: Colors.grey[200],
      ),
    );
  }
}
