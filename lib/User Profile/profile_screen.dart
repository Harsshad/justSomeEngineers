import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codefusion/global_resources/constants/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:blur/blur.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  Stream<DocumentSnapshot<Map<String, dynamic>>> _getUserStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception("User not logged in");
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> _getMentorStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception("User not logged in");
    }

    return FirebaseFirestore.instance
        .collection('mentors')
        .doc(uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Blurred and colored background
          Positioned.fill(
            child: Image.network(
              Constants.bannerDefault, // Replace with your profile background image URL
              fit: BoxFit.cover,
            ).blurred(
              blur: 10,
              overlay: Container(
                color: Colors.purple.withOpacity(0.5),
              ),
            ),
          ),
          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: _getUserStream(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (userSnapshot.hasError || !userSnapshot.hasData || !userSnapshot.data!.exists) {
                return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: _getMentorStream(),
                  builder: (context, mentorSnapshot) {
                    if (mentorSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (mentorSnapshot.hasError || !mentorSnapshot.hasData || !mentorSnapshot.data!.exists) {
                      return const Center(
                        child: Text('Error loading profile data or data unavailable'),
                      );
                    }

                    final data = mentorSnapshot.data!.data()!;
                    return _buildProfileContent(context, data, isMentor: true);
                  },
                );
              }

              final data = userSnapshot.data!.data()!;
              return _buildProfileContent(context, data, isMentor: false);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, Map<String, dynamic> data, {required bool isMentor}) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 80),
          // Profile Picture
          Center(
            child: CircleAvatar(
              radius: 60,
              backgroundImage: data['portfolioUrl']  != null
                  ? NetworkImage(data['portfolioUrl'])
                  : const AssetImage(Constants.default_profile) as ImageProvider,
            ),
          ),
          const SizedBox(height: 10),
          // Name and Email
          Text(
            data['fullName'] ?? 'Unknown' ?? ['username'] ?? 'Unknown' ?? ['full_name'] ?? 'Unknown',
            style: GoogleFonts.lato(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            data['email'] ?? 'Unknown',
            style: GoogleFonts.lato(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          if (isMentor && data.containsKey('bio') && data['bio'].isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              data['bio'],
              style: GoogleFonts.lato(
                fontSize: 16,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}