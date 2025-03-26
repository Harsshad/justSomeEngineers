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
  const ChatScreen({super.key});

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
      // drawer: const DrawerWidget(),
      appBar: _buildAppBar(context),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUserList(showMentors: false), // Users
          _buildUserList(showMentors: true), // Mentors
        ],
      ),
    );
  }

  // App Bar with Search Bar
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.blueGrey[900],
      elevation: 10,
      shadowColor: Colors.black.withOpacity(0.3),
      title: Row(
        children: [
          Text(
            'Dev Chat',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: AnimatedSearchBar(
              controller: _searchController,
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),
        ],
      ),
      bottom: TabBar(
        controller: _tabController,
        labelStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 16),
        indicatorColor: Colors.tealAccent,
        indicatorWeight: 4,
        tabs: const [
          Tab(text: "Users"),
          Tab(text: "Mentors"),
        ],
      ),
    );
  }

  // Build User List
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
            .where((user) =>
                (showMentors
                    ? user["role"] == "Mentor"
                    : user["role"] == "User") &&
                user["email"] != _authService.getCurrentUser()?.email &&
                (user["fullName"]
                        ?.toLowerCase()
                        .contains(_searchQuery.toLowerCase()) ??
                    false))
            .toList();

        return users.isEmpty
            ? const Center(
                child: Text(
                  "No users found",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  return _buildUserListItem(users[index]);
                },
              );
      },
    );
  }

  // User List Tile
  Widget _buildUserListItem(Map<String, dynamic> userData) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserChatPage(
              receiverName:
                  userData["fullName"] ?? userData["email"] ?? 'No data',
              receiverID: userData["uid"] ?? "Invalid Mentor ID",
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 6,
              spreadRadius: 2,
              offset: const Offset(2, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.grey[300],
              backgroundImage: userData["profileImage"] != null &&
                      userData["profileImage"].isNotEmpty
                  ? NetworkImage(userData["profileImage"])
                  : const AssetImage(Constants.default_profile)
                      as ImageProvider,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                userData["fullName"] ?? userData["email"] ?? 'No data',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
