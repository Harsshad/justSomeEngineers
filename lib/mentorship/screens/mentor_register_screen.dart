import 'package:codefusion/global_resources/auth/auth_methods.dart';
import 'package:codefusion/meet%20&%20chat/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MentorRegisterScreen extends StatefulWidget {
  const MentorRegisterScreen({super.key, required this.onTap});

  final VoidCallback? onTap;

  @override
  State<MentorRegisterScreen> createState() => _MentorRegisterScreenState();
}

class _MentorRegisterScreenState extends State<MentorRegisterScreen> {
  final AuthMethods _authMethods = AuthMethods();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _professionController = TextEditingController();

  // Register function
void register() async {
  try {
    // Create mentor details
    Map<String, dynamic> mentorDetails = {
      'fullName': _nameController.text,
      'profession': _professionController.text,
      'email': _emailController.text,
    };

    // Step 1: Register the mentor user with mentor details
    UserCredential userCredential = await _authMethods.mentorSignUp(
      _emailController.text,
      _passwordController.text,
      mentorDetails, // Pass mentorDetails
    );

    // Step 2: Store additional mentor data in Firestore
    if (userCredential.user != null) {
      // Store mentor data in Firestore
      await _firestore
          .collection('mentors')
          .doc(userCredential.user!.uid)
          .set({
        'fullName': _nameController.text,
        'profession': _professionController.text,
        'email': _emailController.text,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Show success message and navigate to the mentor details page
      showSnackBar(context, 'Mentor registered successfully!');
      
      // Use userCredential.user!.uid as mentorId
      Navigator.pushNamed(
        context,
        '/mentor_details',
        arguments: userCredential.user!.uid, // Pass mentorId here
      );
    }
  } catch (e) {
    showSnackBar(context, e.toString());
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: 'Full Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _professionController,
              decoration: const InputDecoration(hintText: 'Profession'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(hintText: 'Email'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(hintText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: register,
              child: const Text('Register as Mentor'),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(
                context,
                '/mentor_login',
              ),
              child: const Text(
                'Already have an account? Login',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
