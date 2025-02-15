import 'package:codefusion/dev_chat/chat/chat_service.dart';
import 'package:codefusion/dev_chat/components/user_tile.dart';
import 'package:codefusion/dev_chat/pages/user_chat_page.dart';
import 'package:codefusion/global_resources/auth/auth_methods.dart';
import 'package:codefusion/global_resources/widgets/drawer_widget.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  ChatScreen({super.key});

  // Chat & Auth services
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        title: const Text('Dev Chat'),
      ),
      drawer: const DrawerWidget(),
      body: _buildUserList(),
    );
  }

  // Build a list of users and mentors except for the current logged-in user
  Widget _buildUserList() {
    return StreamBuilder(
      stream: _chatService.getUsersAndMentorsStream(), //
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          children: snapshot.data!
              .map<Widget>(
                (userData) => _buildUserListItem(userData, context),
              )
              .toList(),
        );
      },
    );
  }

  // Build individual user/mentor list tile
  Widget _buildUserListItem(
      Map<String, dynamic> userData, BuildContext context) {
    if (userData["email"] != _authService.getCurrentUser()!.email) { //this is to make the user's chat itself disappear
      return UserTile(
        text: "${userData["fullName"] ?? userData["email"] ?? 'No data'} (${userData["role"]})",
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserChatPage(
                receiverEmail: userData['fullName'] ?? userData["email"] ?? 'No data',
                receiverID: userData["uid"],
              ),
            ),
          );
        },
      );
    } else {
      return Container();
    }
  }
}
