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
String getChatRoomID(String userID1, String userID2) {
  List<String> ids = [userID1, userID2];
  ids.sort();
  return ids.join("_");
}
//get all users stream except blocked users

  Stream<List<Map<String, dynamic>>> getUserStreamExcludingBlocked() {
  final currentUser = _auth.currentUser;

  if (currentUser == null) {
    return const Stream.empty(); // Return an empty stream if no user is logged in
  }

  return _firestore
      .collection('users')
      .doc(currentUser.uid)
      .collection('BlockedUsers')
      .snapshots()
      .asyncMap((snapshot) async {
    // Get blocked user IDs
    final blockedUsersIds = snapshot.docs.map((doc) => doc.id).toList();

    // Get all users
    final usersSnapshot = await _firestore.collection('users').get();
    final mentorsSnapshot = await _firestore.collection('mentors').get();

    // Combine all users and mentors
    final allUsersAndMentors = [
      ...usersSnapshot.docs.map((doc) {
        final data = doc.data();
        data['uid'] = doc.id; // Add UID to user data
        data['role'] = "User"; // Add role as "User"
        return data;
      }),
      ...mentorsSnapshot.docs.map((doc) {
        final data = doc.data();
        data['uid'] = doc.id; // Add UID to mentor data
        data['role'] = "Mentor"; // Add role as "Mentor"
        return data;
      }),
    ];

    // Filter out blocked users
    return allUsersAndMentors
        .where((user) =>
            user['email'] != currentUser.email &&
            !blockedUsersIds.contains(user['uid']))
        .toList();
  });
}

Future<int> getUnreadMessageCount(String senderID) async {
  final String currentUserID = _auth.currentUser!.uid;
  List<String> ids = [currentUserID, senderID];
  ids.sort();
  String chatRoomID = ids.join("_");

  final unreadMessagesSnapshot = await _firestore
      .collection("chat_rooms")
      .doc(chatRoomID)
      .collection("messages")
      .where("receiverID", isEqualTo: currentUserID)
      .where("isRead", isEqualTo: false)
      .get();

  return unreadMessagesSnapshot.docs.length;
}



  //send message
  Future<void> sendMessage(String receiverID, String message) async {
  if (message.isEmpty || receiverID.isEmpty) {
    // print("❌ Error: Message or receiverID is empty!");
    return;
  }

  final String currentUserID = _auth.currentUser!.uid;
  final String senderEmail = _auth.currentUser!.email!;
  final Timestamp timestamp = Timestamp.now();
  

  Message newMessage = Message(
    senderID: currentUserID,
    senderEmail: senderEmail,
    receiverID: receiverID, // 
    message: message,
    timestamp: timestamp,
    isRead: false,
  );

  List<String> ids = [currentUserID, receiverID];
  ids.sort();
  String chatRoomID = ids.join("_");

  await _firestore
      .collection("chat_rooms")
      .doc(chatRoomID)
      .collection("messages")
      .add(newMessage.toMap());

  // print("✅ Message sent successfully to $receiverID");
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
// Future<Map<String, dynamic>?> getLastMessage(String senderId, String receiverId) async {
//   try {
//     // Generate chat room ID
//     List<String> ids = [senderId, receiverId];
//     ids.sort();
//     String chatRoomID = ids.join("_");

//     QuerySnapshot querySnapshot = await FirebaseFirestore.instance
//         .collection("chat_rooms")
//         .doc(chatRoomID)
//         .collection("messages")
//         .orderBy("timestamp", descending: true)
//         .limit(1)
//         .get();

//     if (querySnapshot.docs.isNotEmpty) {
//       return querySnapshot.docs.first.data() as Map<String, dynamic>;
//     }

//     return null; // No messages found
//   } catch (e) {
//     print("Error fetching last message: $e");
//     return null;
//   }
// }




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
