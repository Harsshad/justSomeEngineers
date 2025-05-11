import 'dart:io';
import 'package:codefusion/global_resources/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'resume_display_page.dart';

class ResumeInputPage extends StatefulWidget {
  const ResumeInputPage({Key? key}) : super(key: key);

  @override
  State<ResumeInputPage> createState() => _ResumeInputPageState();
}

class _ResumeInputPageState extends State<ResumeInputPage> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController currentPositionController =
      TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController educationController = TextEditingController();
  final TextEditingController languagesController = TextEditingController();
  final TextEditingController hobbiesController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  String? profileImage;

  @override
  void dispose() {
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
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
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

    if (fullName.isEmpty ||
        email.isEmpty ||
        currentPosition.isEmpty ||
        bio.isEmpty ||
        address.isEmpty ||
        experienceController.text.trim().isEmpty ||
        educationController.text.trim().isEmpty ||
        languagesController.text.trim().isEmpty ||
        hobbies.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All fields are required!'),
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
          profileImage: profileImage ?? '',
        ),
      ),
    );
  }

  // App Bar with Search Bar
  AppBar _buildAppBar(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/main-home',
            (route) => false,
          );
        },
      ),
      backgroundColor: Colors.blueGrey[900],
      elevation: 10,
      shadowColor: Colors.black.withOpacity(0.3),
      title: Row(
        children: [
          Text(
            'Resume Gen',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: (isDarkMode ? Colors.white : Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      profileImage != null && profileImage!.isNotEmpty
                          ? (kIsWeb
                              ? NetworkImage(profileImage!)
                              : FileImage(File(profileImage!))) as ImageProvider
                          : const AssetImage(
                              Constants.default_profile,
                            ),
                  backgroundColor: Colors.grey[200],
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _pickImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey[900],
                  ),
                  child: Text(
                    'Change Profile Image',
                    style: TextStyle(
                      color: Colors.yellow[100],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField('Full Name', fullNameController),
                _buildTextField('Email', emailController),
                _buildTextField('Address', addressController),
                _buildTextField('Current Position', currentPositionController),
                _buildTextField('Bio', bioController),
                _buildTextField('Experience (Enter each role on a new line)',
                    experienceController),
                _buildTextField('Education (Max 2 entries, each on a new line)',
                    educationController),
                _buildTextField('Languages (Max 5 entries, each on a new line)',
                    languagesController),
                _buildTextField('Hobbies (Max 5 entries, each on a new line)',
                    hobbiesController),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: submitData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey[900],
                  ),
                  child: Text(
                    'Generate Resume',
                    style: TextStyle(
                      color: Colors.yellow[100],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hintText, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        maxLines:
            hintText.contains('Enter') || hintText.contains('entries') ? 5 : 1,
        decoration: InputDecoration(
          labelText: hintText,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
