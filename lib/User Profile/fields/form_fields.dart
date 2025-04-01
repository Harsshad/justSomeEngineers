import 'package:flutter/material.dart';
import '../../global_resources/components/my_textfield.dart';

class FormFields extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  const FormFields({Key? key, required this.formKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MyTextfield(
          focusNode: FocusNode(),
          controller: TextEditingController(),
          hintText: 'Full Name',
          obscureText: false,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Full Name is required';
            }
            if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
              return 'Enter a valid name (letters only)';
            }
            return null;
          },
        ),
        const SizedBox(height: 15),
        MyTextfield(
          focusNode: FocusNode(),
          controller: TextEditingController(),
          hintText: 'Role',
          obscureText: false,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Role is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 15),
        MyTextfield(
          focusNode: FocusNode(),
          controller: TextEditingController(),
          hintText: 'GitHub',
          obscureText: false,
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final uri = Uri.tryParse(value);
              if (uri == null || !uri.hasAbsolutePath) {
                return 'Enter a valid GitHub URL';
              }
            }
            return null;
          },
        ),
        const SizedBox(height: 15),
        MyTextfield(
          focusNode: FocusNode(),
          controller: TextEditingController(),
          hintText: 'LinkedIn',
          obscureText: false,
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final uri = Uri.tryParse(value);
              if (uri == null || !uri.hasAbsolutePath) {
                return 'Enter a valid LinkedIn URL';
              }
            }
            return null;
          },
        ),
        const SizedBox(height: 15),
        MyTextfield(
          focusNode: FocusNode(),
          controller: TextEditingController(),
          hintText: 'Email',
          obscureText: false,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Email is required';
            }
            if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                .hasMatch(value)) {
              return 'Enter a valid email';
            }
            return null;
          },
        ),
        const SizedBox(height: 15),
        MyTextfield(
          focusNode: FocusNode(),
          controller: TextEditingController(),
          hintText: 'Other URL',
          obscureText: false,
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final uri = Uri.tryParse(value);
              if (uri == null || !uri.hasAbsolutePath) {
                return 'Enter a valid URL';
              }
            }
            return null;
          },
        ),
        const SizedBox(height: 15),
        MyTextfield(
          focusNode: FocusNode(),
          controller: TextEditingController(),
          hintText: 'About',
          obscureText: false,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'About is required';
            }
            return null;
          },
        ),
      ],
    );
  }
}