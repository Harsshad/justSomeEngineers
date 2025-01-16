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

  String? experience, expertise, linkedinUrl, portfolioUrl, hourlyRate, bio;
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
    _formKey.currentState!.save();

    // Upload the profile image if selected
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

          DocumentSnapshot mentorSnapshot = await transaction.get(mentorDocRef);

          if (mentorSnapshot.exists) {
            // Merge new data with existing data
            transaction.update(mentorDocRef, mentorData);
          } else {
            // Create new document
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 26),
                const Text(
                  'Mentor Form',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 30),
                ),
                GestureDetector(
                  onTap: _pickProfileImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : _profileImageUrl != null
                            ? NetworkImage(_profileImageUrl!) as ImageProvider
                            : const AssetImage(Constants.default_profile),
                    child: _profileImage == null && _profileImageUrl == null
                        ? const Icon(Icons.add_a_photo, size: 24)
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Experience',
                    fillColor: Theme.of(context).colorScheme.secondary,
                  ),
                  onSaved: (value) => experience = value,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Expertise'),
                  onSaved: (value) => expertise = value,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Hourly Rate'),
                  onSaved: (value) => hourlyRate = value,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Linkedin Url'),
                  onSaved: (value) => linkedinUrl = value,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Portfolio Url'),
                  onSaved: (value) => portfolioUrl = value,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Bio'),
                  onSaved: (value) => bio = value,
                ),
                CheckboxListTile(
                  title: const Text('Paid Mentorship'),
                  value: isPaid,
                  onChanged: (value) => setState(() => isPaid = value!),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _saveDetails,
                  child: const Text('Save Details'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
