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

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
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
            const SizedBox(width: 20),
            Expanded(
              child: AnimatedSearchBar(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
          ],
        ),
        bottom: TabBar(
          unselectedLabelColor: Theme.of(context).colorScheme.primary,
          controller: _tabController,
          labelStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ), // Increased font size
          unselectedLabelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ), // Adjust unselected tab font size
          tabs: const [
            Tab(text: "Users"),
            Tab(text: "Mentors"),
          ],
        ),
      ),
      drawer: const DrawerWidget(),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUserList(showMentors: false), // Users Tab
          _buildUserList(showMentors: true), // Mentors Tab
        ],
      ),
    );
  }

  // Build User List (Can filter between users & mentors)
  Widget _buildUserList({required bool showMentors}) {
    return StreamBuilder(
      stream: _chatService.getUserStreamExcludingBlocked(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading users'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        var users = snapshot.data!
            .where((userData) =>
                (showMentors
                    ? userData["role"] == "Mentor"
                    : userData["role"] == "User") &&
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
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserChatPage(
              receiverName:
                  userData["fullName"] ?? userData["email"] ?? 'No data',
              receiverID: userData["uid"] ??
                  "This mentor has no mentor ID, thats what is causing this issue, try to create a new mentor and then you can chat using that new mentor",
            ),
          ),
        );
      },
    );
  }
}
