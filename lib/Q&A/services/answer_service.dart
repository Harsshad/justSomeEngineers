import 'package:cloud_firestore/cloud_firestore.dart';

class AnswerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getAnswersStream(String questionId) {
    return _firestore.collection('answers').where('questionId', isEqualTo: questionId).snapshots();
  }

  Future<void> postAnswer(String content, String userId, String questionId, {String? imageUrl, String? link}) async {
    await _firestore.collection('answers').add({
      'content': content,
      'userId': userId,
      'questionId': questionId,
      'timestamp': FieldValue.serverTimestamp(),
      'upvotes': 0,
      'downvotes': 0,
      'upvotedBy': [],
      'downvotedBy': [],
      'imageUrl': imageUrl ?? '',
      'link': link ?? '',
    });
  }

  Future<void> updateVote(String answerId, String field, String userId) async {
    final docRef = _firestore.collection('answers').doc(answerId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) {
        throw Exception("Answer does not exist!");
      }

      final data = snapshot.data()!;
      final List<String> upvotedBy = List<String>.from(data['upvotedBy'] ?? []);
      final List<String> downvotedBy = List<String>.from(data['downvotedBy'] ?? []);

      if (field == 'upvotes') {
        if (upvotedBy.contains(userId)) {
          throw Exception("User has already upvoted this answer!");
        }
        upvotedBy.add(userId);
        if (downvotedBy.contains(userId)) {
          downvotedBy.remove(userId);
          transaction.update(docRef, {'downvotes': FieldValue.increment(-1)});
        }
      } else if (field == 'downvotes') {
        if (downvotedBy.contains(userId)) {
          throw Exception("User has already downvoted this answer!");
        }
        downvotedBy.add(userId);
        if (upvotedBy.contains(userId)) {
          upvotedBy.remove(userId);
          transaction.update(docRef, {'upvotes': FieldValue.increment(-1)});
        }
      }

      transaction.update(docRef, {
        field: FieldValue.increment(1),
        'upvotedBy': upvotedBy,
        'downvotedBy': downvotedBy,
      });
    });
  }
}