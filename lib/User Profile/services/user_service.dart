import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  static Future<void> saveUserDetails(
    String userId,
    String usertype,
    String fullName,
    String role,
    String github,
    String linkedin,
    String email,
    String otherUrl,
    String about,
    String? profileImageUrl,
    String? bgBannerImageUrl,
  ) async {
    final data = {
      // 'userId':userId,
      'usertype': usertype,
      'fullName': fullName,
      'role': role,
      'github': github,
      'linkedin': linkedin,
      'email': email,
      'otherUrl': otherUrl,
      'about': about,
      'profileImage': profileImageUrl ?? '',
      'bgBannerImage': bgBannerImageUrl ?? '',
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .set(data, SetOptions(merge: true));
  }
}
