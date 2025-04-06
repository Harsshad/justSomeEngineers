import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codefusion/global_resources/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class MentorDetailsScreen extends StatelessWidget {
  final String mentorId;

  const MentorDetailsScreen({Key? key, required this.mentorId})
      : super(key: key);

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

  Future<bool> _checkIfAlreadyAppliedOrMentee(
      String menteeId, String mentorId) async {
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

  void _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Mentor Details',
          style: TextStyle(
            fontFamily: 'SourceCodePro',
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: isDarkMode ? Colors.white : const Color(0xFF2A2824),
          ),
        ),
        centerTitle: true,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDarkMode
                      ? [Colors.black87, Colors.blueGrey.shade900]
                      : [const Color(0xFFDFD7C2), const Color(0xFFF7DB4C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode ? Colors.white : Colors.black,
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        ),
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
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 900,
          ),
          child: FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('mentors')
                .doc(mentorId)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(
                    child: Text('Error loading mentor details'));
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
                    // Profile Image
                    Center(
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: mentor['profileImage'] != null
                            ? NetworkImage(mentor['profileImage'])
                            : const AssetImage(Constants.default_profile)
                                as ImageProvider,
                        backgroundColor: Colors.grey[200],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Mentor Name
                    Center(
                      child: Text(
                        mentor['fullName'] ?? 'N/A',
                        style:
                            Theme.of(context).textTheme.headlineSmall!.copyWith(
                                  color: (isDarkMode
                                      ? Colors.white
                                      : const Color(0xFF2A2824)),
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Mentor Details Card
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
                            _buildDetailRow('Role:', mentor['role']),
                            _buildDetailRow('Bio:', mentor['bio']),
                            _buildDetailRow('Experience:',
                                '${mentor['experience'] ?? 'N/A'} years'),
                            _buildDetailRow('Expertise:', mentor['expertise']),
                            _buildClickableRow(
                                'LinkedIn:', mentor['linkedinUrl']),
                            _buildClickableRow(
                                'Portfolio:', mentor['portfolioUrl']),
                            _buildDetailRow('Monthly Rate:',
                                '\$${mentor['monthlyRate'] ?? '0'}/month'),
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

                            // Apply Button
                            Center(
                              child: currentUser == null
                                  ? const SizedBox.shrink()
                                  : FutureBuilder<bool>(
                                      future: _checkIfAlreadyAppliedOrMentee(
                                          currentUser.uid, mentorId),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const CircularProgressIndicator();
                                        }
                                        if (snapshot.hasError) {
                                          return const Text(
                                              'Error checking application status');
                                        }
                                        final alreadyAppliedOrMentee =
                                            snapshot.data ?? false;
                                        return alreadyAppliedOrMentee
                                            ? const Text(
                                                'Already applied to this mentor')
                                            : ElevatedButton(
                                                onPressed: () =>
                                                    _applyToMentor(context),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .primary,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 32,
                                                      vertical: 12),
                                                  textStyle: const TextStyle(
                                                      fontSize: 16),
                                                ),
                                                child:  Text(
                                                  'Apply to this Mentor',
                                                  style: TextStyle(
                                                    color: (isDarkMode
                                                        ? Colors.white
                                                        : Colors.black),
                                                  ),
                                                ),
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
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClickableRow(String title, String? url) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap:
                  url != null && url.isNotEmpty ? () => _launchUrl(url) : null,
              child: Text(
                url ?? 'N/A',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
