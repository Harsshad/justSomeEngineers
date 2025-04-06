import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppliedMentorsScreen extends StatelessWidget {
  const AppliedMentorsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
              ? [Colors.black87, Colors.blueGrey.shade900]
              : [const Color(0xFFDFD7C2), const Color(0xFFF7DB4C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Applied Mentors',
            style: TextStyle(
              fontFamily: 'SourceCodePro',
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: isDarkMode ? Colors.white : const Color(0xFF2A2824),
            ),
          ),
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
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: currentUser == null
            ? const Center(child: Text('Please log in to see applied mentors'))
            : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900,),
                child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('mentorRequests')
                        .where('menteeId', isEqualTo: currentUser.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return const Center(
                            child: Text('Error loading applied mentors'));
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('No applied mentors'));
                      }
                
                      final requests = snapshot.data!.docs;
                
                      return ListView.builder(
                        itemCount: requests.length,
                        itemBuilder: (context, index) {
                          final request =
                              requests[index].data() as Map<String, dynamic>;
                          final mentorId = request['mentorId'];
                
                          return FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('mentors')
                                .doc(mentorId)
                                .get(),
                            builder: (context, mentorSnapshot) {
                              if (mentorSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const ListTile(
                                  title: Text('Loading...'),
                                );
                              }
                              if (mentorSnapshot.hasError ||
                                  !mentorSnapshot.hasData ||
                                  !mentorSnapshot.data!.exists) {
                                return const ListTile(
                                  title: Text('Mentor not found'),
                                );
                              }
                
                              final mentor = mentorSnapshot.data!.data()
                                  as Map<String, dynamic>;
                
                              return ListTile(
                                leading: CircleAvatar(
                                  radius: 25,
                                  backgroundImage: mentor['profileImage'] != null
                                      ? NetworkImage(mentor['profileImage'])
                                      : const AssetImage(
                                              'assets/images/default_profile.png')
                                          as ImageProvider,
                                  onBackgroundImageError: (_, __) {
                                    debugPrint('Failed to load profile image');
                                  },
                                ),
                                title: Text(
                                  mentor['fullName'] ?? 'N/A',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode
                                        ? Colors.white
                                        : const Color(0xFF2A2824),
                                  ),
                                ),
                                subtitle: Text(
                                  mentor['email'] ?? 'N/A',
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? Colors.white70
                                        : const Color(0xFF615D52),
                                  ),
                                ),
                                trailing: Text(
                                  request['status'] ?? 'pending',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: request['status'] == 'accepted'
                                        ? Colors.green
                                        : request['status'] == 'rejected'
                                            ? Colors.red
                                            : isDarkMode
                                                ? Colors.white
                                                : const Color(0xFF2A2824),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
              ),
            ),
      ),
    );
  }
}