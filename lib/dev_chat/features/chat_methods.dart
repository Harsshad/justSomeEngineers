import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> acceptChatRequest(String requestId) async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final requestDoc = await _firestore.collection('mentorRequests').doc(requestId).get();
      if (requestDoc.exists) {
        final requestData = requestDoc.data()!;
        await _firestore.collection('mentorRequests').doc(requestId).update({
          'status': 'accepted',
        });
        await _firestore.collection('mentees').add({
          'mentorId': requestData['mentorId'],
          'menteeId': requestData['menteeId'],
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  Future<void> denyChatRequest(String requestId) async {
    await _firestore.collection('mentorRequests').doc(requestId).update({
      'status': 'denied',
    });
  }
}