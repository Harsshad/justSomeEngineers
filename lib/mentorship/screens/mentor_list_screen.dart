import 'dart:ui'; // For ImageFilter.blur
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codefusion/global_resources/constants/constants.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:codefusion/mentorship/screens/mentor_detail_screen.dart';
import 'package:codefusion/mentorship/screens/mentor_form.dart';
import 'package:codefusion/mentorship/screens/mentor_profile_page.dart';
import 'package:codefusion/mentorship/widgets/mentor_card_widget.dart';
import 'package:codefusion/global_resources/components/animated_search_bar.dart';

class MentorListScreens extends StatefulWidget {
  const MentorListScreens({Key? key}) : super(key: key);

  @override
  _MentorListScreensState createState() => _MentorListScreensState();
}

class _MentorListScreensState extends State<MentorListScreens> {
  int _page = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isMentor = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });

    // Check if the current user is a mentor
    _checkIfUserIsMentor();
  }

  Future<void> _checkIfUserIsMentor() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('mentors')
          .doc(currentUser.uid)
          .get();
      if (userDoc.exists) {
        setState(() {
          _isMentor = true;
        });
      }
    }
  }

  void onPagedChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  List<Widget> pages(BuildContext context) {
    return [
      MentorListPage(searchQuery: _searchQuery),
      if (_isMentor) MentorForms(),
      if (_isMentor) const MentorProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
              ? [Colors.black87, Colors.blueGrey.shade900] // Dark mode gradient
              : [const Color(0xFFDFD7C2), const Color(0xFFF7DB4C)], // Light mode gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        extendBody: true,
        backgroundColor: Colors.transparent, // Transparent to show gradient
        appBar: _buildAppBar(isDarkMode),
        bottomNavigationBar: _isMentor ? _buildBottomNavigationBar() : null,
        body: pages(context)[_page],
      ),
    );
  }

  /// Builds the AppBar for the Mentor List Screen
  AppBar? _buildAppBar(bool isDarkMode) {
    if (_page != 0) return null; // Hide AppBar for other pages
    return AppBar(
      backgroundColor: Colors.transparent, // Transparent AppBar
      elevation: 0, // No elevation for a clean look
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
        'Available Mentors',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: isDarkMode ? Colors.white : const Color(0xFF2A2824),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(56.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: AnimatedSearchBar(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
          ),
        ),
      ),
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12), // Blur effect
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode
                    ? [Colors.black87, Colors.blueGrey.shade900] // Dark mode gradient
                    : [const Color(0xFFDFD7C2), const Color(0xFFF7DB4C)], // Light mode gradient
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
    );
  }

  /// Builds the Bottom Navigation Bar for Mentor Pages
  Widget _buildBottomNavigationBar() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return CurvedNavigationBar(
      color: Theme.of(context).colorScheme.background,
      buttonBackgroundColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      items: <Widget>[
        Icon(
          Icons.list_alt_rounded,
          size: 30,
          color: (isDarkMode ? Colors.white :  Colors.black),
        ),
        Icon(
          Icons.description_outlined,
          size: 30,
          color: (isDarkMode ? Colors.white :  Colors.black),
        ),
        Icon(
          Icons.person,
          size: 30,
          color: (isDarkMode ? Colors.white :  Colors.black),
        ),
      ],
      onTap: onPagedChanged,
      index: _page,
    );
  }
}

class MentorListPage extends StatelessWidget {
  final String searchQuery;

  const MentorListPage({Key? key, required this.searchQuery}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('mentors').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Error loading mentors'));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No mentors available'));
            }

            final mentors = snapshot.data!.docs.where((doc) {
              final mentor = doc.data() as Map<String, dynamic>;
              final name = (mentor['fullName'] ?? '').toLowerCase();
              final role = (mentor['role'] ?? '').toLowerCase();
              final expertise = (mentor['expertise'] ?? '').toLowerCase();
              return name.contains(searchQuery) ||
                  role.contains(searchQuery) ||
                  expertise.contains(searchQuery);
            }).toList();

            if (mentors.isEmpty) {
              return const Center(child: Text('No mentors match your search.'));
            }

            return ListView.builder(
              itemCount: mentors.length,
              itemBuilder: (context, index) {
                final mentor = mentors[index].data() as Map<String, dynamic>;
                final mentorId = mentors[index].id;

                return MentorCardWidget(
                  mentor: mentor,
                  mentorId: mentorId,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MentorDetailsScreen(mentorId: mentorId),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}