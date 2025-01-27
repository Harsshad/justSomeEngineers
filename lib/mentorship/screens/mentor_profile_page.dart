import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codefusion/profile%20&%20Q&A/core/constants/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/info_card.dart';


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
    return Scaffold(
      backgroundColor:  Theme.of(context).colorScheme.background,
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _getMentorStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text('Error loading profile data or data unavailable'),
            );
          }

          final data = snapshot.data!.data()!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Material(
                      elevation: 8,
                      shape: const CircleBorder(),
                      shadowColor: Colors.deepPurple.withOpacity(0.4),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: data['profileImage'] != null
                            ? NetworkImage(data['profileImage'])
                            : const AssetImage(Constants.default_profile) as ImageProvider,
                        // backgroundColor: Colors.white,
                        // child: data['profileImage'] != null
                        //     ? null
                        //     : const Icon(Icons.person, size: 90, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  InfoCard(
                    title: 'Full Name',
                    content: data['fullName'] ?? 'N/A',
                    icon: Icons.person,
                  ),
                  InfoCard(
                    title: 'Role',
                    content: data['role'] ?? 'N/A',
                    icon: Icons.assignment_ind,
                  ),
                  InfoCard(
                    title: 'Expertise',
                    content: data['expertise'] ?? 'N/A',
                    icon: Icons.school,
                  ),
                  InfoCard(
                    title: 'Experience',
                    content: '${data['experience'] ?? 'N/A'} years',
                    icon: Icons.timeline,
                  ),
                  InfoCard(
                    title: 'Bio',
                    content: data['bio'] ?? 'N/A',
                    icon: Icons.description,
                  ),
                  InfoCard(
                    title: 'Contact',
                    content: data['email'] ?? 'N/A',
                    icon: Icons.email,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
