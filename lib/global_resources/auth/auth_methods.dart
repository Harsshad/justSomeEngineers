import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codefusion/global_resources/constants/constants.dart';
import 'package:codefusion/global_resources/constants/firebase_constants.dart';
import 'package:codefusion/meet%20&%20chat/utils/utils.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

// final authMehtodsProvider = Provider<AuthMethods>(
//   create: (context) => AuthMethods.instance,
// );

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // CollectionReference get _users => //added this for user profile and q&a
  //     _firestore.collection(FirebaseConstants.usersCollection);

  Stream<User?> get authChanges => _auth.authStateChanges();
  User get user => _auth.currentUser!;

  Future<bool> signInWithGoogle(BuildContext context) async {
    bool res = false;
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // if (userCredential.additionalUserInfo!.isNewUser) {
      //   UserModel userModel = UserModel(
      //     //added this for user profile and q&a
      //     name: userCredential.user!.displayName ?? 'N/A',
      //     profilePic:
      //         userCredential.user!.photoURL ?? Constants.default_profile,
      //     banner: Constants.default_banner,
      //     uid: userCredential.user!.uid,
      //     isAuthenticated: true,
      //     karma: 0,
      //     awards: [],
      //   );
      //   await _users.doc(userCredential.user!.uid).set({userModel.toMap()});
      // }

      User? user = userCredential.user;
      if (user != null) {
        if (userCredential.additionalUserInfo!.isNewUser) {
          await _firestore.collection('users').doc('user.uid').set({
            'username': user.displayName,
            'uid': user.uid,
            'profilePhoto': user.photoURL,
          });
        }
        res = true;
      }
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
      res = false;
    }
    return res;
  }

  Future<void> signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e);
    }
  }

  // Mentor sign-up
  Future<UserCredential> mentorSignUp(
      String email, String password, Map<String, dynamic> mentorDetails) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Save mentor details
      await _firestore.collection('mentors').doc(userCredential.user!.uid).set({
        "uid": userCredential.user!.uid,
        "email": email,
        ...mentorDetails,
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // Mentor sign-in
  Future<UserCredential> mentorSignIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }
}

//errors

//sign in and out functionality
class AuthService {
  //instance of auth
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  //get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  //sign in
  Future<UserCredential> signInWithEmailPassword(String email, password) async {
    try {
      //sign user in
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      //save user info if it doesn't already exists
      _firestore.collection("users").doc(userCredential.user!.uid).set({
        "uid": userCredential.user!.uid,
        "email": email,
      });
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  //sign up
  Future<UserCredential> signUpWithEmailPassword(
      String email, password, userName) async {
    try {
      //create user
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      //save user info in a separate doc
      _firestore.collection("users").doc(userCredential.user!.uid).set({
        // _firestore.collection("Users").doc(userCredential.user!.uid).set({
        "uid": userCredential.user!.uid,
        "email": email,
        "userName": userName,
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // //adding image to firebase storage
  //this wont work since firebase storage has made their sevices paid so switched to https://imagekit.io/dashboard/media-library and now its working
  // Future<String> uploadImageToStorage(
  //     String childName, Uint8List file, bool isPost) async {
  //   Reference ref =
  //       _storage.ref().child(childName).child(_auth.currentUser!.uid);

  //   if (isPost) {
  //     String id = const Uuid().v1();
  //     ref = ref.child(id);
  //   }

  //   UploadTask uploadTask = ref.putData(file);
  //   TaskSnapshot snap = await uploadTask;
  //   String downloadUrl = await snap.ref.getDownloadURL();
  //   return downloadUrl;
  // }
}
