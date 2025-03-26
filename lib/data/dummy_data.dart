import 'package:flutter/material.dart';
class UserData {
  final String fullName;
  final String email;
  final String profileImage;

  UserData({
    required this.fullName,
    required this.email,
    required this.profileImage,
  });
}

// Example dummy data
final dummyUserData = UserData(
  fullName: 'John Doe',
  email: 'john.doe@example.com',
  profileImage: 'assets/images/profile_placeholder.png',
);

// Usage in the LoginScreen or ProfileScreen
// Text('Welcome, ${dummyUserData.fullName}!'),
// Image.asset(dummyUserData.profileImage),
// Text('Email: ${dummyUserData.email}'),
