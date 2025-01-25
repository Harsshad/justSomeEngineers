import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MentorAuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Save or update mentor details in Firestore
  Future<void> saveMentorDetails(String uid, Map<String, dynamic> details) async {
    try {
      await _firestore.collection('mentors').doc(uid).set(details, SetOptions(merge: true));
      print("Mentor details saved successfully.");
    } catch (e) {
      print("Error saving mentor details: $e");
      throw Exception('Error saving mentor details: $e');
    }
  }

  /// Fetch mentor details from Firestore
  Future<Map<String, dynamic>?> getMentorDetails(String uid) async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('mentors').doc(uid).get();
      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print("Error fetching mentor details: $e");
      throw Exception('Error fetching mentor details: $e');
    }
  }

  /// Add a meeting/session to the mentor's history
  Future<void> addMentorMeeting(String uid, String meetingTitle) async {
    try {
      await _firestore
          .collection('mentors')
          .doc(uid)
          .collection('meetings')
          .add({
        'meetingTitle': meetingTitle,
        'timestamp': DateTime.now(),
      });
      print("Meeting added to mentor history successfully.");
    } catch (e) {
      print("Error adding meeting to mentor history: $e");
      throw Exception('Error adding meeting to mentor history: $e');
    }
  }
}
