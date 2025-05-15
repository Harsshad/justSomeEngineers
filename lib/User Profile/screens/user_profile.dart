import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codefusion/global_resources/constants/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../global_resources/themes/theme_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? fullName;
  String? role;
  String? github;
  String? linkedin;
  String? email;
  String? otherUrl;
  String? about;
  String? profileImageUrl;
  String? bgBannerImageUrl;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          fullName = userDoc['fullName'];
          role = userDoc['role'];
          github = userDoc['github'];
          linkedin = userDoc['linkedin'];
          email = userDoc['email'];
          otherUrl = userDoc['otherUrl'];
          about = userDoc['about'];
          profileImageUrl = userDoc['profileImage'];
          bgBannerImageUrl = userDoc['bgBannerImage'];
        });
      }
    }
  }

  @override
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
          'User Profile',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: isDarkMode ? Colors.white : const Color(0xFF2A2824),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: Colors.white,
            ),
            onPressed: themeProvider.toggleTheme,
          ),
        ],
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
          image: DecorationImage(
            image: AssetImage(bgBannerImageUrl ?? Constants.default_banner),
            fit: BoxFit.cover,
            opacity: 0.3, // Adjust opacity to make background image subtle
          ),
        ),
      ),
    );
  }

  /// ✅ Profile Content with Centered Padding
  Widget _buildProfileContent(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 40), // Vertical padding
      child: Center(
        // Centering the content
        child: Container(
          constraints:
              BoxConstraints(maxWidth: 800), // Limiting width for large screens
          padding:
              const EdgeInsets.symmetric(horizontal: 24), // Horizontal padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildProfileImage(),
              const SizedBox(height: 16),
              _buildUserInfoCard(context),
              const SizedBox(height: 24),
              _buildSocialLinks(),
              const SizedBox(height: 32),
              _buildAboutSection(context),
              const SizedBox(height: 40),
              _buildEditButton(context),
            ],
          ),
        ),
      ),
    );
  }

  /// ✅ About Section
  Widget _buildAboutSection(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.blueGrey.shade900
            : const Color(0xFFDFD7C2), // Light mode color
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About Me',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode
                  ? Colors.white
                  : const Color(0xFF2A2824), // Light mode text color
            ),
          ),
          const SizedBox(height: 12),
          Text(
            about ?? 'No about info available.',
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: isDarkMode
                  ? Colors.white70
                  : const Color(0xFF615D52), // Light mode text color
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ Profile Image
  Widget _buildProfileImage() {
    return Center(
      child: CircleAvatar(
        radius: 75,
        backgroundColor: Colors.white.withOpacity(0.1),
        child: ClipOval(
          child: Image.network(
            profileImageUrl ?? Constants.default_profile,
            fit: BoxFit.cover,
            width: 140,
            height: 140,
          ),
        ),
      ),
    );
  }

  /// ✅ User Info Card
  Widget _buildUserInfoCard(BuildContext context) {
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
            fullName ?? 'Full Name',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFFF7DB4C),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            role ?? 'Role',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: Color(0xFF2A2824),
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ Social Links
  Widget _buildSocialLinks() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (github != null) _buildSocialIcon(FontAwesomeIcons.github, github!),
        if (linkedin != null)
          _buildSocialIcon(FontAwesomeIcons.linkedinIn, linkedin!),
        if (otherUrl != null) _buildSocialIcon(Icons.link, otherUrl!),
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon, String url) {
    return GestureDetector(
      onTap: () => _launchURL(url),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF7DB4C),
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, size: 32, color: const Color(0xFF2A2824)),
      ),
    );
  }

  /// ✅ Edit Button
  Widget _buildEditButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => Navigator.pushNamed(context, '/user-profile-form'),
      icon: const Icon(Icons.edit),
      label: Text(
        'Edit Profile',
        style: TextStyle(
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }
}
