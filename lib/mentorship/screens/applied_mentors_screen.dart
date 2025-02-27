import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppliedMentorsScreen extends StatelessWidget {
  const AppliedMentorsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Applied Mentors',
          style: TextStyle(
            fontFamily: 'SourceCodePro',
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        backgroundColor: Colors.blueGrey[800],
      ),
      body: currentUser == null
          ? const Center(child: Text('Please log in to see applied mentors'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('mentorRequests')
                  .where('menteeId', isEqualTo: currentUser.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading applied mentors'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No applied mentors'));
                }

                final requests = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final request = requests[index].data() as Map<String, dynamic>;
                    final mentorId = request['mentorId'];

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('mentors').doc(mentorId).get(),
                      builder: (context, mentorSnapshot) {
                        if (mentorSnapshot.connectionState == ConnectionState.waiting) {
                          return const ListTile(
                            title: Text('Loading...'),
                          );
                        }
                        if (mentorSnapshot.hasError || !mentorSnapshot.hasData || !mentorSnapshot.data!.exists) {
                          return const ListTile(
                            title: Text('Mentor not found'),
                          );
                        }

                        final mentor = mentorSnapshot.data!.data() as Map<String, dynamic>;

                        return ListTile(
                          title: Text(mentor['fullName'] ?? 'N/A'),
                          subtitle: Text(mentor['email'] ?? 'N/A'),
                          trailing: Text(request['status'] ?? 'pending'),
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