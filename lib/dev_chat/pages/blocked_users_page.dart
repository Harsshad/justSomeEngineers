import 'package:codefusion/dev_chat/chat/chat_service.dart';
import 'package:codefusion/dev_chat/components/user_tile.dart';
import 'package:codefusion/global_resources/auth/auth_methods.dart';
import 'package:flutter/material.dart';

class BlockedUsersPage extends StatelessWidget {
  BlockedUsersPage({super.key});

  final ChatService chatService = ChatService();
  final AuthService authService = AuthService();

  //show, confirm unblock box
  void _showUnblockedBox(BuildContext context, String userId) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Unblock Users"),
              content:
                  const Text("Are you sure you want to unblock this user? "),
              actions: [
                //cancel button
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),

                //unblock button
                TextButton(
                  onPressed: () {
                    chatService.unblockUser(userId);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("User Unblocked"),
                      ),
                    );
                  },
                  child: const Text("Unblock"),
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    String userId = authService.getCurrentUser()!.uid;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Blocked Users"),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: chatService.getBlockedUserStream(userId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text("Error Loading..."),
            );
          }
          //loading ...
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final blockedUsers = snapshot.data ?? [];

          //no users
          if (blockedUsers.isEmpty) {
            return const Center(
              child: Text(
                "No blocked Users",
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            );
          }

          //show data
          return ListView.builder(
            itemCount: blockedUsers.length,
            itemBuilder: (context, index) {
              final user = blockedUsers[index];
              return UserTile(
                text: user["email"],
                profileImage: user["profileImage"] ?? '', // Default empty if not available
                // text: user["fullName"] ?? user["email"],
                onTap: () => _showUnblockedBox(context, user['uid']),
              );
            },
          );
        },
      ),
    );
  }
}
