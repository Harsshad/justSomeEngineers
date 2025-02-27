import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MenteesListScreen extends StatelessWidget {
  const MenteesListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Mentees',
          style: TextStyle(
            fontFamily: 'SourceCodePro',
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        backgroundColor: Colors.blueGrey[800],
      ),
      body: currentUser == null
          ? const Center(child: Text('Please log in to see your mentees'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('mentorRequests')
                  .where('mentorId', isEqualTo: currentUser.uid)
                  .where('status', isEqualTo: 'accepted')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading mentees'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No mentees found'));
                }

                final requests = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final request = requests[index].data() as Map<String, dynamic>;
                    final menteeId = request['menteeId'];

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