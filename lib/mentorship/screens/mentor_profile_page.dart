import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MentorProfilePage extends StatelessWidget {
  const MentorProfilePage({Key? key}) : super(key: key);

  Stream<DocumentSnapshot<Map<String, dynamic>>> _getMentorStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception("User not logged in");
    }

    return FirebaseFirestore.instance.collection('mentors').doc(uid).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _getMentorStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('Error loading profile data or data unavailable'));
        }

        final data = snapshot.data!.data()!;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: data['profileImage'] != null
                      ? NetworkImage(data['profileImage'])
                      : null,
                  child: data['profileImage'] == null
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Name: ${data['fullName'] ?? 'N/A'}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Expertise: ${data['expertise'] ?? 'N/A'}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Experience: ${data['experience'] ?? 'N/A'} years',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Bio: ${data['bio'] ?? 'N/A'}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Contact: ${data['email'] ?? 'N/A'}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        );
      },
    );
  }
}
