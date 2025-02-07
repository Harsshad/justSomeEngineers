import 'package:codefusion/global_resources/components/my_button.dart';
import 'package:codefusion/global_resources/components/my_textfield.dart';
import 'package:codefusion/global_resources/auth/auth_methods.dart';
import 'package:codefusion/global_resources/components/sign_in_button.dart';

import 'package:flutter/material.dart';
import '../meet & chat/widgets/custom_button.dart';
import '../global_resources/constants/constants.dart';

class LoginScreen extends StatefulWidget {
  // Constructor with `onTap` callback
  const LoginScreen({super.key, required this.onTap});

  final void Function()? onTap;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthMethods _authMethods = AuthMethods();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  // final TextEditingController _fullNameController = TextEditingController();

  // Login method
  void login(BuildContext context) async {
    // Get auth service
    final authService = AuthService();
    try {
      await authService.signInWithEmailPassword(
        _emailController.text,
        _passwordController.text,
        // _fullNameController.text,
      );
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
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   actions: [
      //     TextButton(
      //       onPressed: () {},
      //       child: const Text(
      //         'Skip',
      //         style: TextStyle(fontWeight: FontWeight.bold),
      //       ),
      //     ),
      //   ],
      // ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 15),
              //logo here
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Image.asset(
                  Constants.logoPath,
                  height: 200, // Adjust height as needed
                  fit: BoxFit.contain,
                ),
              ),
              const Text(
                'Start your Journey where Innovators Connect and Opportunities Ignite! 🚀 \nCodeFusion',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),
              
              // Email textfield
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
              const SizedBox(height: 15),
              // Login button
              MyButton(
                text: "Login Here",
                onTap: () => login(context),
              ),
              // const SizedBox(height: 15),

              // Google Sign-In button
              const SignInButton(),
              // CustomButton( 
              //   text: 'Google Sign In',
              //   onPressed: () async {
              //     bool res = await _authMethods.signInWithGoogle(context);
              //     if (res) {
              //       Navigator.pushNamed(context, '/home');
              //     }
              //   },
              // ),
              const SizedBox(height: 15),
              // Register now
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Not a member? ",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: Text(
                      "Register now.. ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Want to become a Mentor? ",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/mentor_register'),
                    child: Text(
                      "Register now.. ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 75),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
