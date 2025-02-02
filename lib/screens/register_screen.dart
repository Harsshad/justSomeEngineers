import 'dart:developer';

import 'package:codefusion/global_resources/auth/auth_methods.dart';
import 'package:flutter/material.dart';

import '../global_resources/components/my_button.dart';
import '../global_resources/components/my_textfield.dart';
import '../global_resources/constants/constants.dart';

class RegisterScreen extends StatelessWidget {
  //email and password controller
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPwController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();

  //tap to go to register page
  final void Function()? onTap;

  RegisterScreen({super.key, required this.onTap});

  //register function
  void register(BuildContext context) {
    //get auth service
    final _auth = AuthService();

    //password match -> create new user
    if (_passwordController.text == _confirmPwController.text) {
      try {
        _auth.signUpWithEmailPassword(
          _emailController.text,
          _passwordController.text,
          _fullNameController.text,
        );
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(e.toString()),
          ),
        );
      }
    }
    //passwords don't match -> show error
    else {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text("Passwords don't match!"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //logo
              Image.asset(
                Constants.logoPath,
                height: 150,
              ),
              // Icon(
              //   Icons.message,
              //   size: 60,
              //   color: Theme.of(context).colorScheme.primary,
              //),

              const SizedBox(height: 50),
              //welcome back msg

              Text(
                "Let's create an account for you!! ",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 25),

              MyTextfield(
                hintText: 'Full Name',
                obscureText: false,
                controller: _fullNameController,
                focusNode: FocusNode(),
              ),
              const SizedBox(height: 10),

              //pw textfield
              MyTextfield(
                hintText: 'Email',
                obscureText: false,
                controller: _emailController,
                focusNode: FocusNode(), //this is not correct
              ),

              const SizedBox(height: 10),

              MyTextfield(
                hintText: 'Password',
                obscureText: true,
                controller: _passwordController,
                focusNode: FocusNode(), //this is not correct
              ),

              const SizedBox(height: 10),

              //confrim password
              MyTextfield(
                hintText: 'Confirm Password',
                obscureText: true,
                controller: _confirmPwController,
                focusNode: FocusNode(), //this is not correct
              ),

              const SizedBox(height: 25),

              //login button

              MyButton(
                text: "Register here",
                onTap: () =>
                    register(context), //why am I facing error over here
              ),

              const SizedBox(height: 25),

              //register now
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                  GestureDetector(
                    onTap: onTap,
                    child: Text(
                      "Login now.. ",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account as a Mentor? ",
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/mentor_login'),
                    child: Text(
                      "Login now.. ",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
