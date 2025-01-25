import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codefusion/mentorship/screens/mentor_list_screen.dart';
// import 'package:codefusion/mentorship/screens/mentor_form.dart';

import 'package:codefusion/screens/main_home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'login_or_register.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // User logged in
          if (snapshot.hasData) {
            // Determine if the user is a mentor
            FirebaseFirestore.instance
                .collection('mentors')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .get()
                .then((doc) {
              if (doc.exists) {
                return const MentorListScreens(); 
              }
            });

            return  MainHomeScreen(); // User home screen
          } else {
            // User not logged in
            return const LoginOrRegister();
          }
        },
      ),
    );
  }
}
