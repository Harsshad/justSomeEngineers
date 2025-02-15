import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codefusion/dev_chat/models/message.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  //get instance of firestore & auth
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<Map<String, dynamic>>> getUsersAndMentorsStream() {
    return _firestore.collection("users").snapshots().asyncMap(
      (userSnapshot) async {
        final users = userSnapshot.docs.map((doc) {
          final user = doc.data();
          user["role"] = "User";
          return user;
        }).toList();

        final mentorSnapshot = await _firestore.collection("mentors").get();
        final mentors = mentorSnapshot.docs.map((doc) {
          final mentor = doc.data();
          mentor["role"] = "Mentor";
          return mentor;
        }).toList();

        return [...users, ...mentors];
      },
    );
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
}
