import 'dart:ui';

import 'package:flutter/material.dart';
import 'history_meeting_screen.dart';
import 'meeting_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _page = 0;

  void onPagedChanged(int page) {
    _page = page;
    setState(() {});
  }

  List<Widget> pages = [
    const MeetingScreen(),
    const HistoryMeetingScreen(),
  ];

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
        backgroundColor: Colors.transparent, // Transparent to show gradient
        appBar: _page == 0
            ? AppBar(
                backgroundColor: Colors.transparent, // Transparent AppBar
                elevation: 0, // No elevation for a clean look
                title: Text(
                  'Meet & Chat',
                  style: TextStyle(
                    fontFamily: 'SourceCodePro',
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: isDarkMode ? Colors.white : const Color(0xFF2A2824),
                  ),
                ),
                centerTitle: true,
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
              )
            : null, 
        body: Column(
          children: [
            const SizedBox(height: 25),
            Expanded(child: pages[_page]),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: isDarkMode ?   Colors.blueGrey[150]: Colors.blueGrey[900],
          selectedFontSize: 14,
          unselectedFontSize: 14,
          selectedItemColor: isDarkMode ? Colors.blueGrey[800] :Colors.white  ,
          unselectedItemColor: isDarkMode ? Colors.blueGrey[400]: Colors.white70  ,
          currentIndex: _page,
          onTap: onPagedChanged,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.comment_bank),
              label: 'Meet & Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.lock_clock,color: (isDarkMode ? Colors.white : Colors.black)),
              label: 'Meetings',
            ),
          ],
        ),
      ),
    );
  }
}