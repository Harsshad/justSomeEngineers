import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codefusion/global_resources/constants/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../config.dart'; // Import the config file
import '../../global_resources/components/my_textfield.dart';

class UserProfileForm extends StatefulWidget {
  const UserProfileForm({Key? key}) : super(key: key);

  @override
  State<UserProfileForm> createState() => _UserProfileFormState();
}

class _UserProfileFormState extends State<UserProfileForm> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final fullNameController = TextEditingController();
  final roleController = TextEditingController();
  final githubController = TextEditingController();
  final linkedinController = TextEditingController();
  final emailController = TextEditingController();
  final otherUrlController = TextEditingController();
  final aboutController = TextEditingController();

  final fullNameFocus = FocusNode();
  final roleFocus = FocusNode();
  final githubFocus = FocusNode();
  final linkedinFocus = FocusNode();
  final emailFocus = FocusNode();
  final otherUrlFocus = FocusNode();
  final aboutFocus = FocusNode();

  Uint8List? _profileImage;
  Uint8List? _bgBannerImage;
  String? _profileImageUrl;
  String? _bgBannerImageUrl;

  Future<void> _pickProfileImage() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        Uint8List imageBytes = await pickedFile.readAsBytes();
        setState(() {
          _profileImage = imageBytes;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No image selected')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _pickBgBannerImage() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        Uint8List imageBytes = await pickedFile.readAsBytes();
        setState(() {
          _bgBannerImage = imageBytes;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No image selected')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<String> _uploadImageToImageKit(Uint8List file, String fileName) async {
    try {
      var request =
          http.MultipartRequest('POST', Uri.parse(Config.imagekitUrl));
      request.headers['Authorization'] =
          'Basic ' + base64Encode(utf8.encode(Config.privateKey + ':'));
      request.fields['fileName'] = fileName;
      request.fields['publicKey'] = Config.publicKey;
      request.fields['folder'] = '/user_profile';
      request.files.add(http.MultipartFile.fromBytes('file', file,
          filename: 'user-profile.jpg'));

      var response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final decodedData = jsonDecode(responseData);
        return decodedData['url'];
      } else {
        throw Exception('Failed to upload image');
      }
    } catch (e) {
      throw Exception('Image upload error: $e');
    }
  }

  Future<void> _saveDetails() async {
    if (_formKey.currentState!.validate()) {
      final fullName = fullNameController.text;
      final role = roleController.text;
      final github = githubController.text;
      final linkedin = linkedinController.text;
      final email = emailController.text;
      final otherUrl = otherUrlController.text;
      final about = aboutController.text;

      if (_profileImage != null) {
        try {
          _profileImageUrl =
              await _uploadImageToImageKit(_profileImage!, 'profile.jpg');
          print("Profile image uploaded successfully: $_profileImageUrl");
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error uploading profile image: $e')),
          );
          return;
        }
      }

      if (_bgBannerImage != null) {
        try {
          _bgBannerImageUrl =
              await _uploadImageToImageKit(_bgBannerImage!, 'banner.jpg');
          print("Background banner uploaded successfully: $_bgBannerImageUrl");
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error uploading background banner: $e')),
          );
          return;
        }
      }

      User? user = _auth.currentUser;
      if (user != null) {
        Map<String, dynamic> userData = {
          'fullName': fullName,
          'role': role,
          'github': github,
          'linkedin': linkedin,
          'email': email,
          'otherUrl': otherUrl,
          'about': about,
          'profileImage': _profileImageUrl ?? '',
          'bgBannerImage': _bgBannerImageUrl ?? '',
          'updatedAt': FieldValue.serverTimestamp(),
        };

        try {
          await _firestore.runTransaction((transaction) async {
            DocumentReference userDocRef =
                _firestore.collection('users').doc(user.uid);

            DocumentSnapshot userSnapshot = await transaction.get(userDocRef);
            if (userSnapshot.exists) {
              transaction.update(userDocRef, userData);
            } else {
              transaction.set(userDocRef, userData);
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User details saved successfully!')),
          );
          Navigator.pushNamed(
              context, '/main-home'); // Navigate to user profile screen
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving details: $e')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'User Profile Form',
          style: TextStyle(
            fontFamily: 'SourceCodePro',
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        backgroundColor: Colors.blueGrey[800],
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/main-home');
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      GestureDetector(
                        onTap: _pickBgBannerImage,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: _bgBannerImage != null
                                ? Image.memory(
                                    _bgBannerImage!,
                                    height: 150,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  )
                                : (_bgBannerImageUrl != null
                                    ? Image.network(
                                        _bgBannerImageUrl!,
                                        height: 150,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        height: 150,
                                        width: double.infinity,
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.add_photo_alternate,
                                          size: 50,
                                          color: Colors.grey,
                                        ),
                                      )),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -50,
                        left: MediaQuery.of(context).size.width / 2 - 80,
                        child: GestureDetector(
                          onTap: _pickProfileImage,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 60,
                              backgroundImage: _profileImage != null
                                  ? MemoryImage(_profileImage!)
                                  : (_profileImageUrl != null
                                      ? NetworkImage(_profileImageUrl!)
                                      : const AssetImage(
                                              Constants.default_profile)
                                          as ImageProvider),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -57,
                        left: MediaQuery.of(context).size.width / 2 + 10,
                        child: IconButton(
                          icon: Icon(
                            Icons.add_a_photo,
                            size: 26,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                          onPressed: _pickProfileImage,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 60),
                  const Text(
                    "Upload Profile Image",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ..._buildFormFields(),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 24),
                      child: Text(
                        'Edit Profile',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.surface,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 90),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFormFields() {
    return [
      MyTextfield(
        hintText: 'Full Name',
        obscureText: false,
        controller: fullNameController,
        focusNode: fullNameFocus,
      ),
      const SizedBox(height: 15),
      MyTextfield(
        hintText: 'Role',
        obscureText: false,
        controller: roleController,
        focusNode: roleFocus,
      ),
      const SizedBox(height: 15),
      MyTextfield(
        hintText: 'GitHub',
        obscureText: false,
        controller: githubController,
        focusNode: githubFocus,
      ),
      const SizedBox(height: 15),
      MyTextfield(
        hintText: 'LinkedIn',
        obscureText: false,
        controller: linkedinController,
        focusNode: linkedinFocus,
      ),
      const SizedBox(height: 15),
      MyTextfield(
        hintText: 'Email',
        obscureText: false,
        controller: emailController,
        focusNode: emailFocus,
      ),
      const SizedBox(height: 15),
      MyTextfield(
        hintText: 'Other URL',
        obscureText: false,
        controller: otherUrlController,
        focusNode: otherUrlFocus,
      ),
      const SizedBox(height: 15),
      MyTextfield(
        hintText: 'About',
        obscureText: false,
        controller: aboutController,
        focusNode: aboutFocus,
      ),
    ];
  }
}
