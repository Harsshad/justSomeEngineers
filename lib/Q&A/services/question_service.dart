import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getQuestionsStream() {
    return _firestore.collection('questions').snapshots();
  }

  Future<void> postQuestion(String title, String description, List<String> tags, String userId, {String? imageUrl, String? link}) async {
    await _firestore.collection('questions').add({
      'title': title,
      'description': description,
      'tags': tags,
      'userId': userId,
      'timestamp': FieldValue.serverTimestamp(),
      'imageUrl': imageUrl ?? '',
      'link': link ?? '',
    });
  }

  Stream<DocumentSnapshot> getQuestionStream(String questionId) {
    return _firestore.collection('questions').doc(questionId).snapshots();
  }
}