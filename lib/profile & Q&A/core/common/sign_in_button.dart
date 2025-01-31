import 'package:codefusion/global_resources/auth/auth_methods.dart';
import 'package:codefusion/profile%20&%20Q&A/theme/pallete.dart';
import 'package:flutter/material.dart';

import '../../../global_resources/constants/constants.dart';

class SignInButton extends StatelessWidget {
  const SignInButton({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthMethods _authMethods = AuthMethods();
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: ElevatedButton.icon(
        onPressed: () async {
          bool res = await _authMethods.signInWithGoogle(context);
          if (res) {
            Navigator.pushNamed(context, '/home');
          }
        },
        icon: Image.asset(
          Constants.google,
          width: 35,
        ),
        label: const Text(
          'Continue with Google',
          style: TextStyle(
            fontSize: 18,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Pallete.greyColor,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
