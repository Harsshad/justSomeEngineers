import 'package:codefusion/dev_chat/chat/chat_service.dart';
import 'package:codefusion/dev_chat/components/user_tile.dart';
import 'package:codefusion/global_resources/auth/auth_methods.dart';
import 'package:flutter/material.dart';

class BlockedUsersPage extends StatelessWidget {
  BlockedUsersPage({super.key});

  final ChatService chatService = ChatService();
  final AuthService authService = AuthService();

  // Show unblock confirmation dialog
  void _showUnblockDialog(BuildContext context, String userId) {
    final theme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.secondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          "Unblock User",
          style: TextStyle(color: theme.inversePrimary, fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Are you sure you want to unblock this user?",
          style: TextStyle(color: theme.inversePrimary.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: Colors.redAccent)),
          ),
          TextButton(
            onPressed: () {
              chatService.unblockUser(userId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text("User Unblocked"),
                  backgroundColor: theme.primary,
                ),
              );
            },
            child: Text("Unblock", style: TextStyle(color: Colors.greenAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String userId = authService.getCurrentUser()!.uid;
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/main-home',
              (route) => false,
            );

            // Go back to the previous page
          },
        ),
        title: const Text("Blocked Users"),
        backgroundColor: theme.background,
        foregroundColor: theme.inversePrimary,
        elevation: 4,
        shadowColor: theme.primary.withOpacity(0.2),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: chatService.getBlockedUserStream(userId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text("Error loading...", style: TextStyle(color: theme.inversePrimary)),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: theme.primary));
          }

          final blockedUsers = snapshot.data ?? [];

          if (blockedUsers.isEmpty) {
            return Center(
              child: Text(
                "No blocked users",
                style: TextStyle(fontSize: 16, color: theme.inversePrimary),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(10),
            itemCount: blockedUsers.length,
            separatorBuilder: (context, index) => Divider(color: theme.tertiary.withOpacity(0.5)),
            itemBuilder: (context, index) {
              final user = blockedUsers[index];

              return UserTile(
                text: user["email"],
                profileImage: user["profileImage"] ?? '',
                onTap: () => _showUnblockDialog(context, user['uid']),
              );
            },
          );
        },
      ),
    );
  }
}
