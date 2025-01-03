import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codefusion/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';


class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authChanges => _auth.authStateChanges();
  User get user=>_auth.currentUser!;

  //signOut method
  Future<void> signOut() async {
    await _auth.signOut();
  }
  //signUp method
  Future<String> signUp({
    required String name,
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'email': email,
          'uid': user.uid,
          'profilePhoto': '',
        });
      }
      return 'Success';
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
      return e.message!;
    }
  }

  Future<bool> signInWithGoogle(BuildContext context) async {
    bool res = false;
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;
      // final AuthCredential credential = GoogleAuthProvider.credential(
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        if (userCredential.additionalUserInfo!.isNewUser) {
          await _firestore.collection('users').doc(user.uid).set({
            'name': user.displayName,
            'uid': user.uid,
            'email': user.email,
            'profilePhoto': user.photoURL,
          });
        }
        res = true;
      }
      // return user;
    }on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
      res = false;
    }
    return res;
  }
}
