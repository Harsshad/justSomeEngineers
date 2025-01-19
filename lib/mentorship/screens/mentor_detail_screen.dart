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
      appBar: AppBar(
        title: const Text('Mentor Details'),
        backgroundColor: Colors.deepPurple[200],
        elevation: 4.0,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('mentors').doc(mentorId).get(),
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
                    radius: 60,
                    backgroundImage: mentor['profileImage'] != null
                        ? NetworkImage(mentor['profileImage'])
                        : const AssetImage(Constants.default_profile) as ImageProvider,
                    backgroundColor: Colors.grey[200],
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    mentor['fullName'] ?? 'N/A',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall!
                        .copyWith(color: Colors.deepPurple[200], fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  shadowColor: Colors.teal.withOpacity(0.5),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bio:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color:Colors.deepPurple[200]),
                        ),
                        Text(
                          mentor['bio'] ?? 'N/A',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Experience:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.deepPurple[200]),
                        ),
                        Text(
                          '${mentor['experience'] ?? 'N/A'} years',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Expertise:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.deepPurple[200]),
                        ),
                        Text(
                          mentor['expertise'] ?? 'N/A',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'LinkedIn:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.deepPurple[200]),
                        ),
                        Text(
                          mentor['linkedinUrl'] ?? 'N/A',
                          style: const TextStyle(fontSize: 14, decoration: TextDecoration.underline),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Portfolio:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.deepPurple[200]),
                        ),
                        Text(
                          mentor['portfolioUrl'] ?? 'N/A',
                          style: const TextStyle(fontSize: 14, decoration: TextDecoration.underline),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Hourly Rate:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.deepPurple[200]),
                        ),
                        Text(
                          '\$${mentor['hourlyRate'] ?? '0'}/hour',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(
                              mentor['isPaid'] == true ? Icons.monetization_on : Icons.volunteer_activism,
                              color: mentor['isPaid'] == true ? Colors.green : Colors.blue,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              mentor['isPaid'] == true
                                  ? 'This mentor offers paid mentorship.'
                                  : 'This mentor offers free mentorship.',
                              style: TextStyle(
                                fontSize: 14,
                                color: mentor['isPaid'] == true ? Colors.green : Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
