import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codefusion/global_resources/constants/constants.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:codefusion/mentorship/screens/mentor_detail_screen.dart';
import 'package:codefusion/mentorship/screens/mentor_form.dart';
import 'package:codefusion/mentorship/screens/mentor_profile_page.dart';
import 'package:codefusion/mentorship/widgets/mentor_card_widget.dart';

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

  // Check if the current user is a mentor
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

  onPagedChanged(int page) {
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
    return Scaffold(
      extendBody: true,
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Available Mentors',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: _page == 0
            ? PreferredSize(
                preferredSize: const Size.fromHeight(56.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search mentors...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
              )
            : null,
      ),
      bottomNavigationBar: _isMentor
          ? CurvedNavigationBar(
              color:Theme.of(context).colorScheme.background,
              buttonBackgroundColor: Colors.transparent,  //transparency not working 
              backgroundColor: Colors.transparent,
              items: <Widget>[
                Icon(
                  Icons.list_alt_rounded,
                  size: 30,
                  color: Theme.of(context).colorScheme.primary,
                ),
                Icon(
                  Icons.description_outlined,
                  size: 30,
                  color: Theme.of(context).colorScheme.primary,
                ),
                Icon(
                  Icons.person,
                  size: 30,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
              onTap: onPagedChanged,
              index: _page,
            )
          : null, // No BottomNavigationBar for non-mentor users
      // Commenting out the existing BottomNavigationBar
      // bottomNavigationBar: _isMentor
      //     ? BottomNavigationBar(
      //         backgroundColor: Theme.of(context).colorScheme.tertiary,
      //         selectedFontSize: 14,
      //         unselectedFontSize: 14,
      //         selectedItemColor: Colors.grey[600],
      //         unselectedItemColor: Colors.grey[400],
      //         currentIndex: _page,
      //         onTap: onPagedChanged,
      //         items: const [
      //           BottomNavigationBarItem(
      //             icon: Icon(Icons.list_alt_rounded),
      //             label: 'Mentor List',
      //           ),
      //           BottomNavigationBarItem(
      //             icon: Icon(Icons.description_outlined),
      //             label: 'Mentor Form',
      //           ),
      //           BottomNavigationBarItem(
      //             icon: Icon(Icons.person),
      //             label: 'Mentor Profile',
      //           ),
      //         ],
      //       )
      //     : null, // No BottomNavigationBar for non-mentor users
      body: pages(context)[_page],
    );
  }
}

class MentorListPage extends StatelessWidget {
  final String searchQuery;

  const MentorListPage({Key? key, required this.searchQuery}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
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
    );
  }
}