import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codefusion/profile%20&%20Q&A/core/constants/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../components/my_textfield.dart';

class MentorForms extends StatefulWidget {
  const MentorForms({Key? key}) : super(key: key);

  @override
  State<MentorForms> createState() => _MentorFormsState();
}

class _MentorFormsState extends State<MentorForms> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final experienceController = TextEditingController();
  final expertiseController = TextEditingController();
  final hourlyRateController = TextEditingController();
  final linkedinUrlController = TextEditingController();
  final portfolioUrlController = TextEditingController();
  final bioController = TextEditingController();

  final experienceFocus = FocusNode();
  final expertiseFocus = FocusNode();
  final hourlyRateFocus = FocusNode();
  final linkedinFocus = FocusNode();
  final portfolioFocus = FocusNode();
  final bioFocus = FocusNode();

  bool isPaid = false;

  File? _profileImage;
  String? _profileImageUrl;

  Future<void> _pickProfileImage() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
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

  Future<String> _uploadImage(File image) async {
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('mentor_profiles/${DateTime.now().toIso8601String()}');
    await storageRef.putFile(image);
    return await storageRef.getDownloadURL();
  }

  Future<void> _saveDetails() async {
    if (_formKey.currentState!.validate()) {
      final experience = experienceController.text;
      final expertise = expertiseController.text;
      final hourlyRate = hourlyRateController.text;
      final linkedinUrl = linkedinUrlController.text;
      final portfolioUrl = portfolioUrlController.text;
      final bio = bioController.text;

      if (_profileImage != null) {
        try {
          _profileImageUrl = await _uploadImage(_profileImage!);
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
          'experience': experience,
          'expertise': expertise,
          'linkedinUrl': linkedinUrl,
          'portfolioUrl': portfolioUrl,
          'hourlyRate': hourlyRate,
          'bio': bio,
          'isPaid': isPaid,
          'profileImage': _profileImageUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        };

        try {
          await _firestore.runTransaction((transaction) async {
            DocumentReference mentorDocRef =
                _firestore.collection('mentors').doc(user.uid);

            DocumentSnapshot mentorSnapshot =
                await transaction.get(mentorDocRef);

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
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Mentor Form', style: TextStyle(fontSize: 24)),
      //   centerTitle: true,
      //   backgroundColor: Colors.deepPurple,
      //   elevation: 5,
      //   shadowColor: Colors.deepPurpleAccent,
      // ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade100, Colors.deepPurple.shade50],
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
                            ? FileImage(_profileImage!)
                            : (_profileImageUrl != null
                                ? NetworkImage(_profileImageUrl!)
                                : const AssetImage(Constants.default_profile)
                                    as ImageProvider),
                        child: _profileImage == null && _profileImageUrl == null
                            ? const Icon(Icons.add_a_photo, size: 30)
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._buildFormFields(),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    activeColor: Colors.deepPurple,
                    title: const Text('Paid Mentorship',
                        style: TextStyle(fontSize: 18)),
                    value: isPaid,
                    onChanged: (value) => setState(() => isPaid = value!),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 137, 87, 223),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      child: Text(
                        'Save Details',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.surface),
                      ),
                    ),
                  ),
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
      ),
      const SizedBox(height: 15),
      MyTextfield(
        hintText: 'Hourly Rate',
        obscureText: false,
        controller: hourlyRateController,
        focusNode: hourlyRateFocus,
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
      ),
    ];
  }
}
