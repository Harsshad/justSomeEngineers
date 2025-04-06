import 'dart:async'; // For StreamSubscription
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codefusion/dev_chat/chat/chat_service.dart';
import 'package:codefusion/dev_chat/pages/user_chat_page.dart';
import 'package:codefusion/global_resources/auth/auth_methods.dart';
import 'package:codefusion/global_resources/components/animated_search_bar.dart';
import 'package:codefusion/global_resources/constants/constants.dart'
    show Constants;
import 'package:codefusion/global_resources/widgets/drawer_widget.dart';
import 'package:codefusion/global_resources/widgets/responsive_layout.dart';
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
  StreamSubscription? _userStreamSubscription;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Listen to the user stream to prevent "Bad state: Stream has been disposed"
    _userStreamSubscription =
        _chatService.getUserStreamExcludingBlocked().listen((event) {
      // Handle stream updates if needed
    });
  }

  @override
  void dispose() {
    // Dispose of the TabController and TextEditingController
    _tabController.dispose();
    _searchController.dispose();

    // Cancel the stream subscription to avoid "Bad state: Stream has been disposed"
    _userStreamSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileLayout: _buildMobileLayout(context),
      tabletLayout: _buildTabletLayout(context),
      webLayout: _buildWebLayout(context),
    );
  }

  // Mobile Layout
  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      drawer: const DrawerWidget(),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUserList(showMentors: false), // Users
          _buildUserList(showMentors: true), // Mentors
        ],
      ),
    );
  }

  // Tablet Layout
  Widget _buildTabletLayout(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      drawer: const DrawerWidget(),
      body: Row(
        children: [
          const SizedBox(
            width: 250, // Fixed width for the drawer
            child: DrawerWidget(),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUserList(showMentors: false), // Users
                _buildUserList(showMentors: true), // Mentors
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Web Layout
  Widget _buildWebLayout(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Row(
        children: [
          const SizedBox(
            width: 300, // Wider drawer for web
            child: DrawerWidget(),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUserList(showMentors: false), // Users
                _buildUserList(showMentors: true), // Mentors
              ],
            ),
          ),
        ],
      ),
    );
  }

  // App Bar with Search Bar
  AppBar _buildAppBar(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/main-home',
            (route) => false,
          );
        },
      ),
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
              color: (isDarkMode ? Colors.white : Colors.black),
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
        labelStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        labelColor: Colors.white,
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
  final currentUserID = _authService.getCurrentUser()?.uid;

  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection("chat_rooms")
        .doc(_chatService.getChatRoomID(currentUserID!, userData["uid"]))
        .collection("messages")
        .where("receiverID", isEqualTo: currentUserID)
        .where("isRead", isEqualTo: false)
        .snapshots(),
    builder: (context, snapshot) {
      int unreadCount = 0;

      if (snapshot.hasData) {
        unreadCount = snapshot.data!.docs.length;
      }

      return InkWell(
        onTap: () {
          WidgetsBinding.instance.addPostFrameCallback((_) {
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
          });
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
                    : const AssetImage('assets/images/default_profile.png')
                        as ImageProvider,
                onBackgroundImageError: (_, __) {
                  debugPrint('Failed to load profile image');
                },
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
              if (unreadCount > 0)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}
}