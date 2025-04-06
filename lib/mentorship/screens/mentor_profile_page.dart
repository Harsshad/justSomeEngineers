import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codefusion/global_resources/constants/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../global_resources/themes/theme_provider.dart';
import '../widgets/info_card.dart';

class MentorProfilePage extends StatelessWidget {
  const MentorProfilePage({Key? key}) : super(key: key);

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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode ? Colors.white : const Color(0xFF2A2824),
          ),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/main-home',
              (route) => false,
            );
          },
        ),
        title: Text(
          'Mentor Profile',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            // letterSpacing: 1.2,
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
      body: Stack(
        children: [
          _buildBackground(isDarkMode),
          _buildProfileContent(context),
        ],
      ),
    );
  }

  /// ✅ Background Widget
  Widget _buildBackground(bool isDarkMode) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [Colors.black87, Colors.blueGrey.shade900]
                : [const Color(0xFFDFD7C2), const Color(0xFFF7DB4C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }

  /// ✅ Profile Content
  Widget _buildProfileContent(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
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
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 800),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildProfileImage(data),
                  const SizedBox(height: 16),
                  _buildUserInfoCard(context, data),
                  const SizedBox(height: 24),
                  _buildAdditionalInfo(data),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// ✅ Profile Image
  Widget _buildProfileImage(Map<String, dynamic> data) {
    return Center(
      child: CircleAvatar(
        radius: 75,
        backgroundColor: Colors.white.withOpacity(0.1),
        child: ClipOval(
          child: Image.network(
            data['profileImage'] ?? Constants.default_profile,
            fit: BoxFit.cover,
            width: 140,
            height: 140,
          ),
        ),
      ),
    );
  }

  /// ✅ User Info Card
  Widget _buildUserInfoCard(BuildContext context, Map<String, dynamic> data) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF615D52).withOpacity(0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            data['fullName'] ?? 'Full Name',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFFF7DB4C),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data['role'] ?? 'Role',
            style:  TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: (isDarkMode ? Colors.white :  Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ Additional Info
  Widget _buildAdditionalInfo(Map<String, dynamic> data) {
    return Column(
      children: [
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
    );
  }
}