import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codefusion/dev_talk/features/chat_methods.dart';
import 'package:codefusion/Q&A/screen/user_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  void _sendChatRequest(String receiverId) async {
    await ChatMethods().sendChatRequest(receiverId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chat request sent')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Users and Mentors'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<QuerySnapshot>>(
              stream: StreamZip([
                FirebaseFirestore.instance.collection('users').snapshots(),
                FirebaseFirestore.instance.collection('mentors').snapshots(),
              ]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading users and mentors'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No users or mentors available'));
                }

                final users = snapshot.data![0].docs.where((doc) {
                  final user = doc.data() as Map<String, dynamic>;
                  final name = (user['full_name'] ?? '').toLowerCase();
                  final email = (user['email'] ?? '').toLowerCase();
                  return email.contains(_searchQuery) || name.contains(_searchQuery);
                }).toList();

                final mentors = snapshot.data![1].docs.where((doc) {
                  final mentor = doc.data() as Map<String, dynamic>;
                  // final name = (mentor['username'] ?? '').toLowerCase();
                  final name = (mentor['fullName'] ?? '').toLowerCase();
                  final email = (mentor['email'] ?? '').toLowerCase();
                  return email.contains(_searchQuery) || name.contains(_searchQuery);
                }).toList();

                final results = [...users, ...mentors];

                if (results.isEmpty) {
                  return const Center(child: Text('No users or mentors match your search.'));
                }

                return ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final result = results[index].data() as Map<String, dynamic>;
                    final userId = results[index].id;

                    return ListTile(
                      title: Text(result['full_name'] ?? result['username'] ?? result['fullName'] ?? 'N/A'),
                      // title: Text(result['userName'] ?? 'N/A'),
                      subtitle: Text(result['email'] ?? 'N/A'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            
                            builder: (context) => UserProfileScreen(userId: userId),
                          ),
                        );
                      },
                      trailing: IconButton(
                        icon: const Icon(Icons.chat),
                        onPressed: () => _sendChatRequest(userId),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}