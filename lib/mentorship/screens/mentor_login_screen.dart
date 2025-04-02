import 'package:codefusion/global_resources/components/my_textfield.dart';
import 'package:codefusion/global_resources/auth/auth_methods.dart';
import 'package:codefusion/meet%20&%20chat/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MentorLoginScreen extends StatefulWidget {
  const MentorLoginScreen({super.key, required this.onTap});

  final VoidCallback? onTap;

  @override
  State<MentorLoginScreen> createState() => _MentorLoginScreenState();
}

class _MentorLoginScreenState extends State<MentorLoginScreen> {
  final AuthMethods _authMethods = AuthMethods();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Login function
  void login() async {
    try {
      UserCredential userCredential = await _authMethods.mentorSignIn(
        _emailController.text,
        _passwordController.text,
      );
      if (userCredential.user != null) {
        // Navigate to mentor's home screen or desired page
        // Navigator.pushNamed(context, '/mentor-form-widget');  //instead redirect to home
        Navigator.pushNamed(context, '/main-home'); //instead redirect to home
        // Navigator.pushNamed(context, '/mentorship');
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Login Failed'),
            content: Text('Invalid email or password.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 900,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MyTextfield(
                  hintText: 'Email',
                  obscureText: false,
                  controller: _emailController,
                  focusNode: FocusNode(),
                ),
                const SizedBox(height: 10),
                // Password textfield
                MyTextfield(
                  hintText: 'Password',
                  obscureText: true,
                  controller: _passwordController,
                  focusNode: FocusNode(),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                  onPressed: login,
                  child: const Text('Login as Mentor'),
                ),
                const SizedBox(
                  height: 15,
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    '/mentor_register',
                  ),
                  child: Text(
                    'Don’t have an account? Sign up',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
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
}
