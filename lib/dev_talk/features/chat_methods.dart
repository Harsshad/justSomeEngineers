import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> sendChatRequest(String receiverId) async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      await _firestore.collection('chatRequests').add({
        'senderId': currentUser.uid,
        'receiverId': receiverId,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> acceptChatRequest(String requestId) async {
    await _firestore.collection('chatRequests').doc(requestId).update({
      'status': 'accepted',
    });
  }

  Future<void> rejectChatRequest(String requestId) async {
    await _firestore.collection('chatRequests').doc(requestId).update({
      'status': 'rejected',
    });
  }
}