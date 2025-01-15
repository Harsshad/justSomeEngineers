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
            //user is logged in

            if (snapshot.hasData) {
              return const MainHomeScreen();
            }
            //user is not logged in
            else {
              return const LoginOrRegister();
            }
          }),
    );
  }
}
