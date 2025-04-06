import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codefusion/config.dart';
import 'package:codefusion/global_resources/constants/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../global_resources/components/my_textfield.dart';

class MentorForms extends StatefulWidget {
  const MentorForms({Key? key}) : super(key: key);

  @override
  State<MentorForms> createState() => _MentorFormsState();
}

class _MentorFormsState extends State<MentorForms> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final experienceController = TextEditingController();
  final expertiseController = TextEditingController();
  final monthlyRateController = TextEditingController();
  final linkedinUrlController = TextEditingController();
  final portfolioUrlController = TextEditingController();
  final bioController = TextEditingController();
  final roleController = TextEditingController();

  final roleFocus = FocusNode();
  final experienceFocus = FocusNode();
  final expertiseFocus = FocusNode();
  final monthlyRateFocus = FocusNode();
  final linkedinFocus = FocusNode();
  final portfolioFocus = FocusNode();
  final bioFocus = FocusNode();

  bool isPaid = false;

  Uint8List? _profileImage;
  String? _profileImageUrl;

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

  // Updated function to upload profile image to ImageKit
  Future<String> _uploadImageToImageKit(Uint8List file) async {
    const String imagekitUrl = Config.imagekitUrl;
    const String publicKey = Config.publicKey; // Updated to use config
    const String privateKey = Config.privateKey; // Updated to use config

    try {
      var request = http.MultipartRequest('POST', Uri.parse(imagekitUrl));
      request.headers['Authorization'] =
          'Basic ' + base64Encode(utf8.encode(privateKey + ':'));
      request.fields['fileName'] = '${_auth.currentUser!.uid}.jpg';
      request.fields['publicKey'] = publicKey; // Updated
      request.files.add(
          http.MultipartFile.fromBytes('file', file, filename: 'profile.jpg'));

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
      final role = roleController.text;
      final experience = experienceController.text;
      final expertise = expertiseController.text;
      final monthlyRate = monthlyRateController.text;
      final linkedinUrl = linkedinUrlController.text;
      final portfolioUrl = portfolioUrlController.text;
      final bio = bioController.text;

      if (_profileImage != null) {
        try {
          _profileImageUrl =
              await _uploadImageToImageKit(_profileImage!); // Updated
          print("Image uploaded successfully: $_profileImageUrl");
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error uploading image: $e')),
          );
          return;
        }
      }

      User? user = _auth.currentUser;
      if (user != null) {
        Map<String, dynamic> mentorData = {
          'uid': user.uid,
          'role': role,
          'experience': experience,
          'expertise': expertise,
          'linkedinUrl': linkedinUrl,
          'portfolioUrl': portfolioUrl,
          'monthlyRate': monthlyRate,
          'bio': bio,
          'isPaid': isPaid,
          'profileImage':
              _profileImageUrl ?? '', // Ensure a default empty string if null
          'updatedAt': FieldValue.serverTimestamp(),
        };

        try {
          await _firestore.runTransaction((transaction) async {
            DocumentReference mentorDocRef =
                _firestore.collection('mentors').doc(user.uid);

            DocumentSnapshot mentorSnapshot =
                await transaction.get(mentorDocRef);
            Navigator.pushNamed(context, '/main-home');
            if (mentorSnapshot.exists) {
              transaction.update(mentorDocRef, mentorData);
            } else {
              transaction.set(mentorDocRef, mentorData);
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mentor details saved successfully!')),
          );
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
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
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 900,
              ),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 20), // Add spacing above CircleAvatar
                      Stack(
                        children: [
                          GestureDetector(
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
                          Positioned(
                            bottom: -6,
                            left: 80,
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
                      const SizedBox(height: 16),
                      const Text(
                        "Upload an Image ",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ..._buildFormFields(),
                      const SizedBox(height: 16),
                      CheckboxListTile(
                        activeColor: Theme.of(context).colorScheme.primary,
                        title: const Text('Paid Mentorship',
                            style: TextStyle(fontSize: 18)),
                        value: isPaid,
                        onChanged: (value) => setState(() => isPaid = value!),
                      ),
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
                            'Save Details',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: (isDarkMode ? Colors.white :  Colors.black),
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
        ),
      ),
    );
  }

  List<Widget> _buildFormFields() {
    return [
      MyTextfield(
        hintText: 'Role',
        obscureText: false,
        controller: roleController,
        focusNode: roleFocus,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Role is required';
          }
          return null;
        },
      ),
      const SizedBox(height: 15),
      MyTextfield(
        hintText: 'Experience',
        obscureText: false,
        controller: experienceController,
        focusNode: experienceFocus,
      ),
      const SizedBox(height: 15),
      MyTextfield(
        hintText: 'Expertise',
        obscureText: false,
        controller: expertiseController,
        focusNode: expertiseFocus,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Expertise is required';
          }
          return null;
        },
      ),
      const SizedBox(height: 15),
      MyTextfield(
        hintText: 'Monthly Rate',
        obscureText: false,
        controller: monthlyRateController,
        focusNode: monthlyRateFocus,
      ),
      const SizedBox(height: 15),
      MyTextfield(
        hintText: 'Linkedin URL',
        obscureText: false,
        controller: linkedinUrlController,
        focusNode: linkedinFocus,
      ),
      const SizedBox(height: 15),
      MyTextfield(
        hintText: 'Portfolio URL',
        obscureText: false,
        controller: portfolioUrlController,
        focusNode: portfolioFocus,
      ),
      const SizedBox(height: 15),
      MyTextfield(
        hintText: 'Bio',
        obscureText: false,
        controller: bioController,
        focusNode: bioFocus,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Bio is required';
          }
          return null;
        },
      ),
    ];
  }
}