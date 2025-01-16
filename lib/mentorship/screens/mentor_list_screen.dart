import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codefusion/mentorship/screens/mentor_detail_screen.dart';
import 'package:codefusion/mentorship/screens/mentor_form_widget.dart';
import 'package:codefusion/mentorship/widgets/mentor_card_widget.dart';
import 'package:codefusion/mentorship/widgets/search_bar_widget.dart';
import 'package:flutter/material.dart';

class MentorListScreens extends StatefulWidget {
  const MentorListScreens({Key? key}) : super(key: key);

  @override
  _MentorListScreensState createState() => _MentorListScreensState();
}

class _MentorListScreensState extends State<MentorListScreens> {
  int _page = 0;

  onPagedChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  List<Widget> pages = [
    const MentorListPage(),   // Mentor List page widget
    const MentorForms(),      // Mentor Form widget
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Mentors'),
        bottom: _page == 0 // Display search bar only on Mentor List page
            ? PreferredSize(
                preferredSize: const Size.fromHeight(56.0),
                child: SearchBarWidget(
                  searchController: TextEditingController(),
                  onChanged: (value) {
                    // search logic
                  },
                ),
              )
            : null,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).colorScheme.background,
        selectedFontSize: 14,
        unselectedFontSize: 14,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        currentIndex: _page,
        onTap: onPagedChanged,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.comment_bank),
              label: 'Mentor List'),
          BottomNavigationBarItem(
              icon: Icon(Icons.lock_clock),
              label: 'Mentor Form'),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 25),
          Expanded(child: pages[_page]),
        ],
      ),
    );
  }
}

class MentorListPage extends StatefulWidget {
  const MentorListPage({Key? key}) : super(key: key);

  @override
  _MentorListPageState createState() => _MentorListPageState();
}

class _MentorListPageState extends State<MentorListPage> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

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
          return name.contains(_searchQuery) || role.contains(_searchQuery);
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
                // Move the onTap logic here
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
