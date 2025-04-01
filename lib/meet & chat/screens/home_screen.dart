
import 'package:flutter/material.dart';


import 'history_meeting_screen.dart';
import 'meeting_screen.dart';
import '../utils/colors.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  int _page = 0;

  onPagedChanged(int page) {
    _page = page;
    setState(() {});
  }

  List<Widget> pages = [
    const MeetingScreen(),
    const HistoryMeetingScreen(),
    // const Text('Contacts'),
    // const Text('Settings'),
  ];

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/main-home',
              (route) => false,
            );

            // Go back to the previous page
          },
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.background,
        title: const Text('Meet & Chat'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 25,),
          Expanded(child: pages[_page]),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).colorScheme.background,
        selectedFontSize: 14,
        unselectedFontSize: 14,
        selectedItemColor: Colors.grey[600],
        unselectedItemColor: Colors.grey[400],
        currentIndex: _page,
        onTap: onPagedChanged,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(
                Icons.comment_bank,
              ),
              label: 'Meet & Chat'),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.lock_clock,
              ),
              label: 'Meetings'),
          // BottomNavigationBarItem(
          //     icon: Icon(
          //       Icons.person_outline,
          //     ),
          //     label: 'Contacts'),
          // BottomNavigationBarItem(
          //     icon: Icon(
          //       Icons.settings,
          //     ),
          //     label: 'Settings'),
        ],
      ),
    );
  }
}
