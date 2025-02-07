import 'package:cloud_firestore/cloud_firestore.dart';

class Answer {
  final String id;
  final String content;
  final String userId;
  final String questionId;
  final DateTime timestamp;
  final int upvotes;
  final int downvotes;
  final List<String> upvotedBy;
  final List<String> downvotedBy;

  Answer({
    required this.id,
    required this.content,
    required this.userId,
    required this.questionId,
    required this.timestamp,
    required this.upvotes,
    required this.downvotes,
    required this.upvotedBy,
    required this.downvotedBy,
  });

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      id: json['id'],
      content: json['content'],
      userId: json['userId'],
      questionId: json['questionId'],
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      upvotes: json['upvotes'],
      downvotes: json['downvotes'],
      upvotedBy: List<String>.from(json['upvotedBy']),
      downvotedBy: List<String>.from(json['downvotedBy']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'userId': userId,
      'questionId': questionId,
      'timestamp': timestamp,
      'upvotes': upvotes,
      'downvotes': downvotes,
      'upvotedBy': upvotedBy,
      'downvotedBy': downvotedBy,
    };
  }
}