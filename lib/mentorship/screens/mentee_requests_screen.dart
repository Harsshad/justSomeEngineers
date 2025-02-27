import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codefusion/dev_chat/features/chat_methods.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


class MenteeRequestsScreen extends StatelessWidget {
  const MenteeRequestsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mentee Requests',
          style: TextStyle(
            fontFamily: 'SourceCodePro',
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        backgroundColor: Colors.blueGrey[800],
      ),
      body: currentUser == null
          ? const Center(child: Text('Please log in to see mentee requests'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('mentorRequests')
                  .where('mentorId', isEqualTo: currentUser.uid)
                  .where('status', isEqualTo: 'pending')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading mentee requests'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No mentee requests'));
                }

                final requests = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final request = requests[index].data() as Map<String, dynamic>;
                    final menteeId = request['menteeId'];
                    final requestId = requests[index].id;

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('users').doc(menteeId).get(),
                      builder: (context, menteeSnapshot) {
                        if (menteeSnapshot.connectionState == ConnectionState.waiting) {
                          return const ListTile(
                            title: Text('Loading...'),
                          );
                        }
                        if (menteeSnapshot.hasError || !menteeSnapshot.hasData || !menteeSnapshot.data!.exists) {
                          return const ListTile(
                            title: Text('Mentee not found'),
                          );
                        }

                        final mentee = menteeSnapshot.data!.data() as Map<String, dynamic>;

                        return ListTile(
                          title: Text(mentee['fullName'] ?? 'N/A'),
                          subtitle: Text(mentee['email'] ?? 'N/A'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check),
                                onPressed: () async {
                                  await ChatMethods().acceptChatRequest(requestId);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Mentee request accepted')),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () async {
                                  await ChatMethods().denyChatRequest(requestId);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Mentee request denied')),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}