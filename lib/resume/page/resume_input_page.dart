import 'dart:io';

import 'package:codefusion/global_resources/components/my_textfield.dart';
import 'package:codefusion/global_resources/constants/constants.dart';
import 'package:codefusion/global_resources/widgets/responsive_layout.dart';
import 'package:codefusion/resume/page/resume_display_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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

  late FocusNode fullNameFocusNode;
  late FocusNode emailFocusNode;
  late FocusNode currentPositionFocusNode;
  late FocusNode bioFocusNode;
  late FocusNode experienceFocusNode;
  late FocusNode educationFocusNode;
  late FocusNode languagesFocusNode;
  late FocusNode hobbiesFocusNode;
  late FocusNode addressFocusNode;

  String? profileImage;

  @override
  void initState() {
    super.initState();
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

    fullNameFocusNode = FocusNode();
    emailFocusNode = FocusNode();
    currentPositionFocusNode = FocusNode();
    bioFocusNode = FocusNode();
    experienceFocusNode = FocusNode();
    educationFocusNode = FocusNode();
    languagesFocusNode = FocusNode();
    hobbiesFocusNode = FocusNode();
    addressFocusNode = FocusNode();

    profileImage = _authMethods.user.photoURL;
  }

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

    fullNameFocusNode.dispose();
    emailFocusNode.dispose();
    currentPositionFocusNode.dispose();
    bioFocusNode.dispose();
    experienceFocusNode.dispose();
    educationFocusNode.dispose();
    languagesFocusNode.dispose();
    hobbiesFocusNode.dispose();
    addressFocusNode.dispose();

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
          profileImage: profileImage ?? '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileLayout: _buildMobileLayout(),
      tabletLayout: _buildTabletLayout(),
      webLayout: _buildWebLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildForm(padding: const EdgeInsets.all(16.0)),
    );
  }

  Widget _buildTabletLayout() {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Center(
        child: Container(
          width: 600, // Fixed width for tablet
          child: _buildForm(padding: const EdgeInsets.all(24.0)),
        ),
      ),
    );
  }

  Widget _buildWebLayout() {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Center(
        child: Container(
          width: 800, // Wider form for web
          child: _buildForm(padding: const EdgeInsets.all(32.0)),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
       leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/main-home',
              (route) => false,
            );

            // Go back to the previous page
          },
        ),
      title: Text(
        'Resume Generator',
        style: TextStyle(
          fontFamily: 'SourceCodePro',
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      backgroundColor: Colors.blueGrey[800],
    );
  }

  Widget _buildForm({required EdgeInsets padding}) {
    return ListView(
      padding: padding,
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: profileImage != null && profileImage!.isNotEmpty
              ? (kIsWeb
                  ? NetworkImage(profileImage!)
                  : FileImage(File(profileImage!))) as ImageProvider
              : const AssetImage(Constants.default_profile),
          backgroundColor: Colors.grey[200],
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: _pickImage,
          child: const Text('Change Profile Image'),
        ),
        const SizedBox(height: 20),
        MyTextfield(
          hintText: 'Full Name',
          obscureText: false,
          controller: fullNameController,
          focusNode: fullNameFocusNode,
        ),
        const SizedBox(height: 16),
        MyTextfield(
          hintText: 'Email',
          obscureText: false,
          controller: emailController,
          focusNode: emailFocusNode,
        ),
        const SizedBox(height: 16),
        MyTextfield(
          hintText: 'Address',
          obscureText: false,
          controller: addressController,
          focusNode: addressFocusNode,
        ),
        const SizedBox(height: 16),
        MyTextfield(
          hintText: 'Current Position',
          obscureText: false,
          controller: currentPositionController,
          focusNode: currentPositionFocusNode,
        ),
        const SizedBox(height: 16),
        MyTextfield(
          hintText: 'Bio',
          obscureText: false,
          controller: bioController,
          focusNode: bioFocusNode,
        ),
        const SizedBox(height: 16),
        MyTextfield(
          hintText: 'Experience (Enter each role on a new line)',
          obscureText: false,
          controller: experienceController,
          focusNode: experienceFocusNode,
        ),
        const SizedBox(height: 16),
        MyTextfield(
          hintText: 'Education (Max 2 entries, each on a new line)',
          obscureText: false,
          controller: educationController,
          focusNode: educationFocusNode,
        ),
        const SizedBox(height: 16),
        MyTextfield(
          hintText: 'Languages (Max 5 entries, each on a new line)',
          obscureText: false,
          controller: languagesController,
          focusNode: languagesFocusNode,
        ),
        const SizedBox(height: 16),
        MyTextfield(
          hintText: 'Hobbies (Max 5 entries, each on a new line)',
          obscureText: false,
          controller: hobbiesController,
          focusNode: hobbiesFocusNode,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: submitData,
          child: const Text(
            'Generate Resume',
            style: TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}