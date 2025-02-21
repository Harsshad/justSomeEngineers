import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codefusion/dev_chat/models/message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatService extends ChangeNotifier {
  //get instance of firestore & auth
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<Map<String, dynamic>>> getUsersAndMentorsStream() {
    return _firestore.collection("users").snapshots().asyncMap(
      (userSnapshot) async {
        final users = userSnapshot.docs.map((doc) {
          final user = doc.data();
          user["role"] = "User";
          user["uid"] = doc.id; // Ensure UID exists
          return user;
        }).toList();

        final mentorSnapshot = await _firestore.collection("mentors").get();
        final mentors = mentorSnapshot.docs.map((doc) {
          final mentor = doc.data();
          mentor["role"] = "Mentor";
          mentor["uid"] = doc.id; // Assign document ID as UID
          return mentor;
        }).toList();

        return [...users, ...mentors];
      },
    );
  }

//get all users stream except blocked users

  Stream<List<Map<String, dynamic>>> getUserStreamExcludingBlocked() {
    final currentUser = _auth.currentUser;

    return _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('BlockedUsers')
        .snapshots()
        .asyncMap((snapshot) async {
      //get blocked user ids
      final blockedUsersIds = snapshot.docs.map((doc) => doc.id).toList();

      //get all users
      final usersSnapshot = await _firestore.collection('users').get();
      final mentorsSnapshot = await _firestore.collection('mentors').get();

      //Combine all users and mentors
      final allUsersAndMentors = [
        ...usersSnapshot.docs.map((doc) => doc.data()..['role'] = "User"),
        ...mentorsSnapshot.docs.map((doc) => doc.data()..['role'] = "Mentor"),
      ];

      //return as stream list
      // return usersSnapshot.docs
      //     .where((doc) =>
      //         doc.data()['email'] != currentUser.email &&
      //         !blockedUsersIds.contains(doc.id))
      //     .map((doc) => doc.data())
      //     .toList();

      return allUsersAndMentors
          .where((user) =>
              user['email'] != currentUser.email &&
              !blockedUsersIds.contains(user['uid']))
          .toList();
    });
  }

  //send message
  Future<void> sendMessage(String receiverID, message) async {
    //get current user info
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    //create a new message
    Message newMessage = Message(
        senderID: currentUserID,
        senderEmail: currentUserEmail,
        receiverID: receiverID,
        message: message,
        timestamp: timestamp);

    //construct chat room ID for the users (sorted to ensure uniqueness)
    List<String> ids = [currentUserID, receiverID];
    ids.sort(); //sort the ids(this ensure the chatroomID is the same for any 2 people)
    String chatRoomID = ids.join("_");

    //add new message
    await _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .add(newMessage.toMap());
  }

  //get message
  Stream<QuerySnapshot> getMessages(String userID, otherUserID) {
    //constructor a chatroom ID for the 2 users
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join("_");

    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  //Report user
  Future<void> reportUser(String messageId, String userId) async {
    final currentUser = _auth.currentUser;
    final report = {
      'reportedBy': currentUser!.uid,
      'messageId': messageId,
      'messageOwnerId': userId,
      'timestamp': FieldValue.serverTimestamp(),
    };
    await _firestore.collection("Reports").add(report);
  }

  //Block user
  Future<void> blockUser(String userId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    // Check if the blocked user is a mentor or a regular user
    final userDoc = await _firestore.collection("users").doc(userId).get();
    final mentorDoc = await _firestore.collection("mentors").doc(userId).get();

    if (userDoc.exists) {
      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('BlockedUsers')
          .doc(userId)
          .set({});
      notifyListeners();
    } else if (mentorDoc.exists) {
      await _firestore
          .collection('mentors')
          .doc(currentUser.uid)
          .collection('BlockedUsers')
          .doc(userId)
          .set({});
      notifyListeners();
    }
  }

  //Unblock user
  Future<void> unblockUser(String blockedUserId) async {
    final currentUser = _auth.currentUser;

    if (currentUser == null) return;

    // Check if the blocked user is a mentor or a regular user
    final userDoc =
        await _firestore.collection("users").doc(blockedUserId).get();
    final mentorDoc =
        await _firestore.collection("mentors").doc(blockedUserId).get();

    if (userDoc.exists) {
      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('BlockedUsers')
          .doc(blockedUserId)
          .delete();
      notifyListeners();
    } else if (mentorDoc.exists) {
      await _firestore
          .collection('mentors')
          .doc(currentUser.uid)
          .collection('BlockedUsers')
          .doc(blockedUserId)
          .delete();
      notifyListeners();
    }
  }

  //Get Blocked user stream

Stream<List<Map<String, dynamic>>> getBlockedUserStream(String userId) {
  return _firestore
      .collection('users') // Start from the "users" collection
      .doc(userId) // Specify the user
      .collection('BlockedUsers') // Access the blocked users subcollection
      .snapshots()
      .asyncMap((snapshot) async {
    final blockedUserIds = snapshot.docs.map((doc) => doc.id).toList();

    final userDocs = await Future.wait(
      blockedUserIds.map((id) async {
        final userDoc = await _firestore.collection('users').doc(id).get();
        if (userDoc.exists) return userDoc.data();

        final mentorDoc = await _firestore.collection('mentors').doc(id).get();
        if (mentorDoc.exists) return mentorDoc.data();

        return null; // In case the document doesn't exist in either collection
      }),
    );

    return userDocs
        .where((data) => data != null)
        .cast<Map<String, dynamic>>()
        .toList();
  });
}


  // Stream<List<Map<String, dynamic>>> getBlockedUserStream(String userId) {
  //   return _firestore
  //       .collection('users')
  //       .doc(userId)
  //       .collection('BlockedUsers')
  //       .snapshots()
  //       .asyncMap((snapshot) async {
  //     //get list of blocked user ids
  //     final blockedUserIds = snapshot.docs.map((doc) => doc.id).toList();

  //     final userDocs = await Future.wait(
  //       blockedUserIds
  //           .map((id) => _firestore.collection('users').doc(id).get()),
  //     );

  //     //return as a list
  //     return userDocs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  //   });
  // }
}
