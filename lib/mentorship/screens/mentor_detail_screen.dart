import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codefusion/profile%20&%20Q&A/core/constants/constants.dart';
import 'package:flutter/material.dart';

class MentorDetailsScreen extends StatelessWidget {
  final String mentorId;

  const MentorDetailsScreen({Key? key, required this.mentorId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mentor Details')),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('mentors')
            .doc(mentorId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading mentor details'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Mentor not found'));
          }

          final mentor = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: mentor['profileImage'] != null
                        ? NetworkImage(mentor['profileImage'])
                        : const AssetImage(Constants.default_profile,)
                            as ImageProvider,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  mentor['fullName'] ?? 'N/A',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                // Text(
                //   mentor['role'] ?? 'N/A',
                //   style: Theme.of(context).textTheme.titleMedium,
                // ),
                const SizedBox(height: 16),
                Text('Bio: ${mentor['bio'] ?? 'N/A'}'),
                const SizedBox(height: 8),
                Text('Experience: ${mentor['experience'] ?? 'N/A'} years'),
                const SizedBox(height: 8),
                Text('Expertise: ${mentor['expertise'] ?? 'N/A'}'),
                const SizedBox(height: 8),
                Text('LinkedIn: ${mentor['linkedinUrl'] ?? 'N/A'}'),
                const SizedBox(height: 8),
                Text('Portfolio: ${mentor['portfolioUrl'] ?? 'N/A'}'),
                const SizedBox(height: 8),
                // Text('Availability: ${mentor['availability'] ?? 'N/A'}'),
                // const SizedBox(height: 8),
                // Text('Communication Modes: ${mentor['communicationModes'] ?? 'N/A'}'),
                const SizedBox(height: 8),
                Text('Hourly Rate: \$${mentor['hourlyRate'] ?? '0'}/hour'),
                const SizedBox(height: 16),
                mentor['isPaid'] == true
                    ? const Text('This mentor offers paid mentorship.',
                        style: TextStyle(color: Colors.green))
                    : const Text('This mentor offers free mentorship.',
                        style: TextStyle(color: Colors.blue)),
              ],
            ),
          );
        },
      ),
    );
  }
}
