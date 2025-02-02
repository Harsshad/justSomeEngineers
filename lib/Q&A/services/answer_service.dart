import 'package:cloud_firestore/cloud_firestore.dart';

class AnswerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getAnswersStream(String questionId) {
    return _firestore.collection('answers').where('questionId', isEqualTo: questionId).snapshots();
  }

  Future<void> postAnswer(String content, String userId, String questionId) async {
    await _firestore.collection('answers').add({
      'content': content,
      'userId': userId,
      'questionId': questionId,
      'timestamp': FieldValue.serverTimestamp(),
      'upvotes': 0,
      'downvotes': 0,
    });
  }

  Future<void> updateVote(String answerId, String field) async {
    final docRef = _firestore.collection('answers').doc(answerId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) {
        throw Exception("Answer does not exist!");
      }
      final newVotes = (snapshot.data()![field] ?? 0) + 1;
      transaction.update(docRef, {field: newVotes});
    });
  }
}