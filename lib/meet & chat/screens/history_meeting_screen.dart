import 'dart:ui';

import 'package:codefusion/meet%20&%20chat/auth/firestore_methods.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryMeetingScreen extends StatelessWidget {
  const HistoryMeetingScreen({Key? key}) : super(key: key);

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
        appBar: AppBar(
          backgroundColor: Colors.transparent, // Transparent AppBar
          elevation: 0, // No elevation for a clean look
          title: Center(
            child: Text(
              'Meeting History',
              style: TextStyle(
                fontFamily: 'SourceCodePro',
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: isDarkMode ? Colors.white : const Color(0xFF2A2824),
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
        ),
        body: StreamBuilder(
          stream: FirestoreMethods().meetingsHistory,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return ListView.builder(
              itemCount: (snapshot.data! as dynamic).docs.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(
                  'Room Name: ${(snapshot.data! as dynamic).docs[index]['meetingName']}',
                  style: TextStyle(
                    fontFamily: 'SourceCodePro',
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.blueGrey[800],
                  ),
                ),
                subtitle: Text(
                  'Joined on ${DateFormat.yMMMd().format((snapshot.data! as dynamic).docs[index]['createdAt'].toDate())}',
                  style: TextStyle(
                    fontFamily: 'SourceCodePro',
                    color: isDarkMode ? Colors.white70 : Colors.blueGrey[600],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}