import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codefusion/global_resources/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MentorDetailsScreen extends StatelessWidget {
  final String mentorId;

  const MentorDetailsScreen({Key? key, required this.mentorId}) : super(key: key);

  Future<void> _applyToMentor(BuildContext context) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await FirebaseFirestore.instance.collection('mentorRequests').add({
        'menteeId': currentUser.uid,
        'mentorId': mentorId,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Application sent to mentor')),
      );
    }
  }

  Future<bool> _checkIfAlreadyAppliedOrMentee(String menteeId, String mentorId) async {
    final requests = await FirebaseFirestore.instance
        .collection('mentorRequests')
        .where('menteeId', isEqualTo: menteeId)
        .where('mentorId', isEqualTo: mentorId)
        .get();

    final mentees = await FirebaseFirestore.instance
        .collection('mentees')
        .where('menteeId', isEqualTo: menteeId)
        .where('mentorId', isEqualTo: mentorId)
        .get();

    return requests.docs.isNotEmpty || mentees.docs.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/main-home',
              (route) => false,
            );

            // Go back to the previous page
          },
        ),
        title: const Text('Mentor Details'),
        backgroundColor: Theme.of(context).colorScheme.background,
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
                    backgroundColor: Theme.of(context).colorScheme.background,
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    mentor['fullName'] ?? 'N/A',
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold),
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
                          'Role:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        Text(
                          mentor['role'] ?? 'N/A',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Bio:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        Text(
                          mentor['bio'] ?? 'N/A',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Experience:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        Text(
                          '${mentor['experience'] ?? 'N/A'} years',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Expertise:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        Text(
                          mentor['expertise'] ?? 'N/A',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'LinkedIn:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        Text(
                          mentor['linkedinUrl'] ?? 'N/A',
                          style: const TextStyle(
                              fontSize: 14,
                              decoration: TextDecoration.underline,
                              color: Colors.blue),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Portfolio:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        Text(
                          mentor['portfolioUrl'] ?? 'N/A',
                          style: const TextStyle(
                              fontSize: 14,
                              decoration: TextDecoration.underline,
                              color: Colors.blue),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Monthly Rate:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        Text(
                          '\$${mentor['monthlyRate'] ?? '0'}/month',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(
                              mentor['isPaid'] == true
                                  ? Icons.monetization_on
                                  : Icons.volunteer_activism,
                              color: mentor['isPaid'] == true
                                  ? Colors.green
                                  : Colors.blue,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              mentor['isPaid'] == true
                                  ? 'This mentor offers paid mentorship.'
                                  : 'This mentor offers free mentorship.',
                              style: TextStyle(
                                fontSize: 14,
                                color: mentor['isPaid'] == true
                                    ? Colors.green
                                    : Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: currentUser == null
                              ? const SizedBox.shrink()
                              : FutureBuilder<bool>(
                                  future: _checkIfAlreadyAppliedOrMentee(currentUser.uid, mentorId),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return const CircularProgressIndicator();
                                    }
                                    if (snapshot.hasError) {
                                      return const Text('Error checking application status');
                                    }
                                    final alreadyAppliedOrMentee = snapshot.data ?? false;
                                    return alreadyAppliedOrMentee
                                        ? const Text('Already applied to this mentor')
                                        : ElevatedButton(
                                            onPressed: () => _applyToMentor(context),
                                            child: const Text('Apply to this Mentor'),
                                          );
                                  },
                                ),
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