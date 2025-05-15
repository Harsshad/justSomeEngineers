import 'dart:typed_data';

import 'package:codefusion/User%20Profile/services/image_service.dart';
import 'package:codefusion/User%20Profile/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../global_resources/components/my_textfield.dart';
import '../../global_resources/constants/constants.dart';

class UserProfileForm extends StatefulWidget {
  const UserProfileForm({Key? key}) : super(key: key);

  @override
  State<UserProfileForm> createState() => _UserProfileFormState();
}

class _UserProfileFormState extends State<UserProfileForm> {
  final _formKey = GlobalKey<FormState>();

  final fullNameController = TextEditingController();
  final roleController = TextEditingController();
  final githubController = TextEditingController();
  final linkedinController = TextEditingController();
  final emailController = TextEditingController();
  final otherUrlController = TextEditingController();
  final aboutController = TextEditingController();

  final fullNameFocusNode = FocusNode();
  final roleFocusNode = FocusNode();
  final githubFocusNode = FocusNode();
  final linkedinFocusNode = FocusNode();
  final emailFocusNode = FocusNode();
  final otherUrlFocusNode = FocusNode();
  final aboutFocusNode = FocusNode();

  Uint8List? _profileImage;
  Uint8List? _bgBannerImage;
  String? _profileImageUrl;
  String? _bgBannerImageUrl;

  Future<void> _pickProfileImage() async {
    final image = await ImageService.pickImage();
    if (image != null) {
      setState(() {
        _profileImage = image;
      });
    }
  }

  Future<void> _pickBgBannerImage() async {
    final image = await ImageService.pickImage();
    if (image != null) {
      setState(() {
        _bgBannerImage = image;
      });
    }
  }

  Future<void> _saveDetails() async {
    if (_formKey.currentState!.validate()) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User not logged in!')),
          );
          return;
        }

        // Upload images if selected
        _profileImageUrl = _profileImage != null
            ? await ImageService.uploadImage(_profileImage!, 'profile.jpg')
            : null;
        _bgBannerImageUrl = _bgBannerImage != null
            ? await ImageService.uploadImage(_bgBannerImage!, 'banner.jpg')
            : null;

        // Save user details
        await UserService.saveUserDetails(
          user.uid,
          'user',
          fullNameController.text,
          roleController.text,
          githubController.text,
          linkedinController.text,
          emailController.text,
          otherUrlController.text,
          aboutController.text,
          _profileImageUrl,
          _bgBannerImageUrl,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );

        Navigator.pushNamed(context, '/onboard-screen');
        // Navigator.pushNamed(context, '/main-home');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDarkMode
                  ? [Colors.black87, Colors.blueGrey.shade900]
                  : [const Color(0xFFDFD7C2), const Color(0xFFF7DB4C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : const Color(0xFF2A2824),
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode ? Colors.white : const Color(0xFF2A2824),
          ),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
                context, '/user-profile', (route) => false);
          },
        ),
      ),
      body: Stack(
        children: [
          _buildBackground(isDarkMode),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800), // Limit width
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildProfileImageSection(isDarkMode),
                      const SizedBox(height: 40),
                      _buildFormFields(isDarkMode),
                      const SizedBox(height: 25),
                      _buildSaveButton(isDarkMode),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ Background with Gradient
  Widget _buildBackground(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
              ? [Colors.black87, Colors.blueGrey.shade900]
              : [const Color(0xFFDFD7C2), const Color(0xFFF7DB4C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  /// ✅ Profile Image and Banner Section
  Widget _buildProfileImageSection(bool isDarkMode) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: _pickBgBannerImage,
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 1.5),
              borderRadius: BorderRadius.circular(12),
              color: Colors.transparent,
              image: _bgBannerImage != null
                  ? DecorationImage(
                      image: MemoryImage(_bgBannerImage!),
                      fit: BoxFit.cover,
                    )
                  : (_bgBannerImageUrl != null
                      ? DecorationImage(
                          image: AssetImage(_bgBannerImageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null),
            ),
            child: _bgBannerImage == null && _bgBannerImageUrl == null
                ? const Center(
                    child: Icon(Icons.add_photo_alternate, size: 50, color: Colors.white),
                  )
                : null,
          ),
        ),
        Positioned(
          bottom: -50,
          child: GestureDetector(
            onTap: _pickProfileImage,
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey[800],
              backgroundImage: _profileImage != null
                  ? MemoryImage(_profileImage!)
                  : (_profileImageUrl != null
                      ? AssetImage(_profileImageUrl!)
                      : const AssetImage(Constants.default_profile) as ImageProvider),
              child: _profileImage == null && _profileImageUrl == null
                  ? const Icon(Icons.add_a_photo, size: 30, color: Colors.white)
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  /// ✅ Form Fields
  Widget _buildFormFields(bool isDarkMode) {
    return Column(
      children: [
        const SizedBox(height: 20),
        MyTextfield(
          hintText: 'Full Name',
          controller: fullNameController,
          validator: _validateName,
          obscureText: false,
          focusNode: fullNameFocusNode,
        ),
        const SizedBox(height: 15),
        MyTextfield(
          hintText: 'Role',
          controller: roleController,
          validator: _validateRequired,
          obscureText: false,
          focusNode: roleFocusNode,
        ),
        const SizedBox(height: 15),
        MyTextfield(
          hintText: 'GitHub',
          controller: githubController,
          validator: _validateURL,
          obscureText: false,
          focusNode: githubFocusNode,
        ),
        const SizedBox(height: 15),
        MyTextfield(
          hintText: 'LinkedIn',
          controller: linkedinController,
          validator: _validateURL,
          obscureText: false,
          focusNode: linkedinFocusNode,
        ),
        const SizedBox(height: 15),
        MyTextfield(
          hintText: 'Email',
          controller: emailController,
          validator: _validateEmail,
          obscureText: false,
          focusNode: emailFocusNode,
        ),
        const SizedBox(height: 15),
        MyTextfield(
          hintText: 'Other URL',
          controller: otherUrlController,
          validator: _validateURL,
          obscureText: false,
          focusNode: otherUrlFocusNode,
        ),
        const SizedBox(height: 15),
        Container(
          height: 150,
          child: TextFormField(
            controller: aboutController,
            validator: _validateRequired,
            maxLines: null,
            expands: true,
            focusNode: aboutFocusNode,
            decoration: InputDecoration(
              
              hintText: 'About',
              filled: true,
              // fillColor: isDarkMode ? Colors.blueGrey.shade800 : Colors.grey[200],
              fillColor: Colors.transparent,
              contentPadding: const EdgeInsets.all(16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black,width: 1.5)  
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// ✅ Save Button
  Widget _buildSaveButton(bool isDarkMode) {
    return ElevatedButton(
      onPressed: _saveDetails,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDarkMode ? Colors.blueGrey[700] : const Color(0xFFF7DB4C),
        foregroundColor: isDarkMode ? Colors.white : const Color(0xFF2A2824),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text('Save Changes', style: TextStyle(fontSize: 16)),
    );
  }

  String? _validateRequired(String? value) =>
      value == null || value.isEmpty ? 'This field is required' : null;

  String? _validateName(String? value) =>
      !RegExp(r'^[a-zA-Z\s]+$').hasMatch(value ?? '')
          ? 'Enter a valid name'
          : null;

  String? _validateURL(String? value) =>
      value != null && value.isNotEmpty && !Uri.tryParse(value)!.hasAbsolutePath
          ? 'Enter a valid URL'
          : null;

  String? _validateEmail(String? value) =>
      !RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
              .hasMatch(value ?? '')
          ? 'Enter a valid email'
          : null;
}