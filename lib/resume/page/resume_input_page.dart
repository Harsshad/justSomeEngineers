import 'dart:io';

import 'package:codefusion/resume/page/resume_display_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../global_resources/auth/auth_methods.dart';

class ResumeInputPage extends StatefulWidget {
  const ResumeInputPage({Key? key}) : super(key: key);

  @override
  State<ResumeInputPage> createState() => _ResumeInputPageState();
}

class _ResumeInputPageState extends State<ResumeInputPage> {
  final AuthMethods _authMethods = AuthMethods();

  late TextEditingController fullNameController;
  late TextEditingController emailController;
  late TextEditingController currentPositionController;
  late TextEditingController bioController;
  late TextEditingController experienceController;
  late TextEditingController educationController;
  late TextEditingController languagesController;
  late TextEditingController hobbiesController;
  late TextEditingController addressController;

  String? profileImage;

  @override
  void initState() {
    super.initState();
    // Initialize text controllers with default values or empty strings
    fullNameController =
        TextEditingController(text: _authMethods.user.displayName ?? '');
    emailController =
        TextEditingController(text: _authMethods.user.email ?? '');
    currentPositionController = TextEditingController();
    bioController = TextEditingController();
    experienceController = TextEditingController();
    educationController = TextEditingController();
    languagesController = TextEditingController();
    hobbiesController = TextEditingController();
    addressController = TextEditingController();
    profileImage = _authMethods.user.photoURL;
  }

  @override
  void dispose() {
    // Dispose of all controllers
    fullNameController.dispose();
    emailController.dispose();
    currentPositionController.dispose();
    bioController.dispose();
    experienceController.dispose();
    educationController.dispose();
    languagesController.dispose();
    hobbiesController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        profileImage = image.path;
      });
    }
  }

  void submitData() {
    String fullName = fullNameController.text.trim();
    String email = emailController.text.trim();
    String currentPosition = currentPositionController.text.trim();
    String bio = bioController.text.trim();
    String address = addressController.text.trim();
    String hobbies = hobbiesController.text.trim();

    if (fullName.isEmpty || currentPosition.isEmpty || hobbies.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Full Name, Current Position, and Hobbies are required!'),
        ),
      );
      return;
    }

    List<String> hobbiesList =
        hobbies.split('\n').where((e) => e.isNotEmpty).toList();
    List<String> experiences = experienceController.text
        .split('\n')
        .where((e) => e.isNotEmpty)
        .toList();
    List<String> educationDetails =
        educationController.text.split('\n').take(2).toList();
    List<String> languages =
        languagesController.text.split('\n').take(5).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResumeDisplayPage(
          fullName: fullName,
          email: email,
          currentPosition: currentPosition,
          bio: bio,
          experiences: experiences,
          address: address,
          educationDetails: educationDetails,
          languages: languages,
          hobbies: hobbiesList,
          profileImageUrl: profileImage ?? '',
        ),
      ),
    );
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
          // Profile image display
          CircleAvatar(
            radius: 50,
            backgroundImage: profileImage != null && profileImage!.isNotEmpty
                ? (profileImage!.startsWith('http')
                    ? NetworkImage(profileImage!)
                    : FileImage(File(profileImage!))) as ImageProvider
                : const AssetImage('assets/images/google.png'),
            backgroundColor: Colors.grey[200],
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _pickImage,
            child: const Text('Change Profile Image'),
          ),
          const SizedBox(height: 20),
          _buildTextField(fullNameController, 'Full Name'),
          _buildTextField(emailController, 'Email'),
          _buildTextField(addressController, 'Address'),
          _buildTextField(currentPositionController, 'Current Position'),
          _buildTextField(bioController, 'Bio', maxLines: 3),
          _buildTextField(
            experienceController,
            'Experience (Enter each role on a new line)',
            maxLines: 5,
          ),
          _buildTextField(
            educationController,
            'Education (Max 2 entries, each on a new line)',
            maxLines: 3,
          ),
          _buildTextField(
            languagesController,
            'Languages (Max 5 entries, each on a new line)',
            maxLines: 3,
          ),
          _buildTextField(
            hobbiesController,
            'Hobbies (Max 5 entries, each on a new line)',
            maxLines: 3,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: submitData,
            child: const Text('Generate Resume', style: TextStyle(color: Colors.white),),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        maxLines: maxLines,
      ),
    );
  }
}
