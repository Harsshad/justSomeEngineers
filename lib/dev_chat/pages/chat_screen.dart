import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codefusion/dev_chat/chat/chat_service.dart';

import 'package:codefusion/dev_chat/pages/user_chat_page.dart';
import 'package:codefusion/global_resources/auth/auth_methods.dart';
import 'package:codefusion/global_resources/components/animated_search_bar.dart';
import 'package:codefusion/global_resources/constants/constants.dart'
    show Constants;
import 'package:codefusion/global_resources/widgets/drawer_widget.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F5F5), // Light background for better contrast
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[800],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Dev Chat',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            AnimatedSearchBar(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ],
        ),
      ),
      drawer: const DrawerWidget(),
      body: Column(
        children: [
          // _buildContactList(),
          Expanded(child: _buildUserList()),
        ],
      ),
    );
  }

  // Top Contact List
  Widget _buildContactList() {
    return StreamBuilder(
      stream: _chatService.getUserStreamExcludingBlocked(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty)
          return const SizedBox();

        List<Map<String, dynamic>> users = snapshot.data!;
        return SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: users.length,
            itemBuilder: (context, index) {
              var user = users[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: user["profileImage"] != null &&
                              user["profileImage"].isNotEmpty
                          ? NetworkImage(user["profileImage"])
                          : const AssetImage(Constants.default_profile)
                              as ImageProvider,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      user["fullName"]?.split(" ")[0] ?? "User",
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // User Chat List
  Widget _buildUserList() {
    return StreamBuilder(
      stream: _chatService.getUserStreamExcludingBlocked(),
      builder: (context, snapshot) {
        if (snapshot.hasError)
          return const Center(child: Text('Error loading users'));
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        var users = snapshot.data!
            .where((userData) =>
                userData["email"] != _authService.getCurrentUser()?.email &&
                (userData["fullName"]
                        ?.toLowerCase()
                        .contains(_searchQuery.toLowerCase()) ??
                    false))
            .toList();

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 10),
          itemCount: users.length,
          itemBuilder: (context, index) {
            return _buildUserListItem(users[index], context);
          },
        );
      },
    );
  }
  
Widget _buildUserListItem(
      Map<String, dynamic> userData, BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: CircleAvatar(
        radius: 25,
        backgroundImage: userData["profileImage"] != null &&
                userData["profileImage"].isNotEmpty
            ? NetworkImage(userData["profileImage"])
            : const AssetImage(Constants.default_profile) as ImageProvider,
      ),
      title: Text(
        userData["fullName"] ?? userData["email"] ?? 'No data',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      // subtitle: const Text("Tap to chat"),
      // trailing: const Icon(Icons.check_circle, color: Colors.green),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserChatPage(
              receiverName:
                  userData["fullName"] ?? userData["email"] ?? 'No data',
              receiverID: userData["uid"] ?? '',
            ),
          ),
        );
      },
    );
  }

// Widget _buildUserListItem(Map<String, dynamic> userData, BuildContext context) {
//   return FutureBuilder<Map<String, dynamic>?>(
//     future: _chatService.getLastMessage(
//         _authService.getCurrentUser()?.uid ?? '', userData["uid"]),
//     builder: (context, snapshot) {
//       String subtitleText = ""; // Default to empty text

//       if (snapshot.connectionState == ConnectionState.waiting) {
//         subtitleText = "Loading...";
//       } else if (snapshot.hasError) {
//         subtitleText = "Error fetching message";
//       } else if (snapshot.hasData && snapshot.data != null) {
//         var lastMessageData = snapshot.data!;
//         subtitleText = lastMessageData["message"]?.toString() ?? ""; // Ensure it's a String
//       }

//       return ListTile(
//         contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//         leading: CircleAvatar(
//           radius: 25,
//           backgroundImage: userData["profileImage"] != null &&
//                   userData["profileImage"].isNotEmpty
//               ? NetworkImage(userData["profileImage"])
//               : const AssetImage(Constants.default_profile) as ImageProvider,
//         ),
//         title: Text(
//           userData["fullName"] ?? userData["email"] ?? 'No data',
//           style: const TextStyle(fontWeight: FontWeight.bold),
//         ),
//         subtitle: subtitleText.isNotEmpty ? Text(subtitleText) : null, // Hide if empty
//         trailing: const Icon(Icons.check_circle, color: Colors.green),
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => UserChatPage(
//                 receiverName: userData["fullName"] ?? userData["email"] ?? 'No data',
//                 receiverID: userData["uid"] ?? '',
//               ),
//             ),
//           );
//         },
//       );
//     },
//   );
// }



}
