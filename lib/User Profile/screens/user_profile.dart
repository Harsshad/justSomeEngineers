import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codefusion/global_resources/constants/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final double coverHeight = 280;
  final double profileHeight = 144;
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
  Widget build(BuildContext context) {
    final top = coverHeight - profileHeight / 2;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'User Profile',
          style: TextStyle(
            fontFamily: 'SourceCodePro',
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        backgroundColor: Colors.blueGrey[800],
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/main-home');
          },
        ),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          buildTop(),
          buildContent(),
        ],
      ),
    );
  }

  Widget buildCoverImage() => Container(
        color: Theme.of(context).colorScheme.primary,
        child: bgBannerImageUrl != null && bgBannerImageUrl!.isNotEmpty
            // child: bgBannerImageUrl != null
            ? Image.network(
                bgBannerImageUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: coverHeight,
              )
            : Image.asset(
                Constants.default_coder_banner,
                fit: BoxFit.cover,
                width: double.infinity,
                height: coverHeight,
              ),
      );

  Widget buildProfileImage() => CircleAvatar(
        radius: profileHeight / 2,
        backgroundColor: Colors.grey.shade800,
        backgroundImage: profileImageUrl != null && profileImageUrl!.isNotEmpty
            ? NetworkImage(profileImageUrl!)
            : const AssetImage(Constants.default_profile) as ImageProvider,
      );

  Widget buildTop() {
    final bottom = profileHeight / 2;
    final top = coverHeight - profileHeight / 2;
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: bottom),
          child: buildCoverImage(),
        ),
        Positioned(
          top: top,
          child: buildProfileImage(),
        ),
      ],
    );
  }

  Widget buildContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Text(
            fullName ?? 'Full Name',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            role ?? 'Role',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (github != null) ...[
                buildSocialIcon(FontAwesomeIcons.github, github!),
                const SizedBox(width: 8),
              ],
              if (linkedin != null) ...[
                buildSocialIcon(FontAwesomeIcons.linkedinIn, linkedin!),
                const SizedBox(width: 8),
              ],
              if (email != null) ...[
                buildSocialIcon(Icons.email_rounded, 'mailto:$email'),
                const SizedBox(width: 8),
              ],
              if (otherUrl != null) buildSocialIcon(Icons.link, otherUrl!),
            ],
          ),
          const SizedBox(height: 16),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'About',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            about ?? 'About information not provided.',
            style: const TextStyle(
              fontSize: 18,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/user-profile-form');
              },
              child: const Text(
                'Edit Profile',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }

  Widget buildSocialIcon(IconData icon, String url) => GestureDetector(
        onTap: () => _launchURL(url),
        child: CircleAvatar(
          radius: 20,
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Icon(
            icon,
            color: Colors.white,
            size: 28,
          ),
        ),
      );

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
