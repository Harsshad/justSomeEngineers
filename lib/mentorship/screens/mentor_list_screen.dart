import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codefusion/mentorship/screens/mentor_detail_screen.dart';
import 'package:codefusion/mentorship/screens/mentor_form.dart';
import 'package:codefusion/mentorship/screens/mentor_profile_page.dart';
import 'package:codefusion/mentorship/widgets/mentor_card_widget.dart';
import 'package:flutter/material.dart';

class MentorListScreens extends StatefulWidget {
  const MentorListScreens({Key? key}) : super(key: key);

  @override
  _MentorListScreensState createState() => _MentorListScreensState();
}

class _MentorListScreensState extends State<MentorListScreens> {
  int _page = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  onPagedChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  List<Widget> pages(BuildContext context) {
    return [
      MentorListPage(searchQuery: _searchQuery), // Pass search query
      const MentorForms(),
      MentorProfilePage(),  
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Mentors'),
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
                    ),
                  ),
                ),
              )
            : null,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _page,
        onTap: onPagedChanged,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Mentor List'),
          BottomNavigationBarItem(icon: Icon(Icons.description_outlined), label: 'Mentor Form'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Mentor Profile'),
        ],
      ),
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
          return name.contains(searchQuery) || role.contains(searchQuery);
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
