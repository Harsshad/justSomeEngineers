import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codefusion/dev_chat/chat/chat_service.dart';
import 'package:codefusion/dev_chat/components/chat_bubble.dart';
import 'package:codefusion/global_resources/auth/auth_methods.dart';
import 'package:codefusion/global_resources/components/my_textfield.dart';
import 'package:codefusion/global_resources/constants/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserChatPage extends StatefulWidget {
  final String receiverName;
  final String receiverID;

  const UserChatPage({
    super.key,
    required this.receiverName,
    required this.receiverID,
  });

  @override
  State<UserChatPage> createState() => _UserChatPageState();
}

class _UserChatPageState extends State<UserChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  FocusNode myFocusNode = FocusNode();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    myFocusNode.addListener(() {
      Future.delayed(
        const Duration(milliseconds: 500),
        () => scrollDown(),
      );
    });
    Future.delayed(
      const Duration(milliseconds: 500),
      () => scrollDown(),
    );
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
    super.dispose();
  }

  void scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
          widget.receiverID, _messageController.text);
      _messageController.clear();
    }
    scrollDown();
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 800;

    return isLargeScreen
        ? _buildLargeScreenLayout(context)
        : _buildMobileLayout(context);
  }

void markMessagesAsRead(String otherUserId) async {
  final currentUserID = FirebaseAuth.instance.currentUser!.uid;
  final chatRoomID = _chatService.getChatRoomID(currentUserID, otherUserId);

  final unreadMessages = await FirebaseFirestore.instance
      .collection("chat_rooms")
      .doc(chatRoomID)
      .collection("messages")
      .where("receiverID", isEqualTo: currentUserID)
      .where("isRead", isEqualTo: false)
      .get();

  for (var doc in unreadMessages.docs) {
    doc.reference.update({"isRead": true});
  }
}
  /// Mobile Layout (Unchanged)
  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.receiverName,
          style: TextStyle(
            fontFamily: 'SourceCodePro',
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        backgroundColor: Colors.blueGrey[800],
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/user-chat-screen');
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          _buildUserInput(),
        ],
      ),
    );
  }

  /// Large Screen Layout
Widget _buildLargeScreenLayout(BuildContext context) {
  return Scaffold(
    body: Row(
      children: [
        // LEFT PANEL: Chat List (30%)
        Container(
          width: MediaQuery.of(context).size.width * 0.3,
          color: Colors.blueGrey[900],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AppBar style heading
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.blueGrey[800],
                child: const Row(
                  children: [
                    Text(
                      'Chats',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Spacer(),
                    Icon(Icons.chat, color: Colors.white70),
                  ],
                ),
              ),

              // Search bar in AppBar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: Colors.blueGrey[800],
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.blueGrey[700],
                    hintText: 'Search...',
                    hintStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.search, color: Colors.white70),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // Chats list
              Expanded(child: _buildChatList()),
            ],
          ),
        ),

        // RIGHT PANEL: Messages Area
        Expanded(
          child: Column(
            children: [
              _buildLargeScreenAppBar(context),
              Expanded(child: _buildMessageList()),
              _buildUserInput(),
            ],
          ),
        ),
      ],
    ),
  );
}


  /// Chat List Widget

 Widget _buildChatList() {
  return StreamBuilder<List<Map<String, dynamic>>>(
    stream: _chatService.getUserStreamExcludingBlocked(),
    builder: (context, snapshot) {
      if (snapshot.hasError) return const Center(child: Text('Error loading chats'));
      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

      var users = snapshot.data ?? [];

      // Filter users based on the search query (name or email)
      users = users.where((user) {
        final fullName = user['fullName']?.toLowerCase() ?? '';
        final email = user['email']?.toLowerCase() ?? '';
        return fullName.contains(_searchQuery) || email.contains(_searchQuery);
      }).toList();

      return ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          return buildChatCard(users[index]);
        },
      );
    },
  );
}

  /// Large Screen AppBar
  Widget _buildLargeScreenAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        widget.receiverName,
        style: TextStyle(
          fontFamily: 'SourceCodePro',
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      backgroundColor: Colors.blueGrey[800],
    );
  }

  /// Message List Widget
  Widget _buildMessageList() {
    String senderID = _authService.getCurrentUser()!.uid;
    return StreamBuilder<QuerySnapshot>(
      stream: _chatService.getMessages(widget.receiverID, senderID),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Text("Error");
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        var messages = snapshot.data?.docs ?? [];

        return ListView.builder(
          controller: _scrollController,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            return _buildMessageItem(messages[index]);
          },
        );
      },
    );
  }

  /// Message Item Widget
  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    bool isCurrentUser = data['senderID'] == _authService.getCurrentUser()!.uid;
    var alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    return Container(
      alignment: alignment,
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          ChatBubble(
            message: data["message"],
            isCurrentUser: isCurrentUser,
            messageId: doc.id,
            userId: data['senderID'],
          ),
        ],
      ),
    );
  }

  Widget buildChatCard(Map<String, dynamic> userData) {
  String senderID = userData['uid'];

  return FutureBuilder<int>(
    future: _chatService.getUnreadMessageCount(senderID),
    builder: (context, snapshot) {
      int unreadCount = snapshot.data ?? 0;

      return ListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundImage: userData['profileImage'] != null &&
                  userData['profileImage'].isNotEmpty
              ? NetworkImage(userData['profileImage'])
              : const AssetImage(Constants.default_profile)
                  as ImageProvider,
          onBackgroundImageError: (_, __) {
            debugPrint('Failed to load profile image');
          },
        ),
        title: Text(
          userData['fullName'] ?? 'N/A',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: unreadCount > 0
            ? CircleAvatar(
                radius: 12,
                backgroundColor: Colors.red,
                child: Text(
                  '$unreadCount',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              )
            : null,
        onTap: () {
          markMessagesAsRead(senderID);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => UserChatPage(
                receiverName: userData['fullName'] ?? 'N/A',
                receiverID: senderID,
              ),
            ),
          );
        },
      );
    },
  );
}


  /// User Input Widget
  Widget _buildUserInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0, left: 16),
      child: Row(
        children: [
          Expanded(
            child: MyTextfield(
              hintText: "Type a message",
              obscureText: false,
              controller: _messageController,
              focusNode: myFocusNode,
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            margin: const EdgeInsets.only(right: 25),
            child: IconButton(
              onPressed: sendMessage,
              icon: const Icon(
                Icons.arrow_upward_rounded,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
