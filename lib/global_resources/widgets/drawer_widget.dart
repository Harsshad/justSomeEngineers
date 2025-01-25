import 'package:codefusion/profile%20&%20Q&A/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:codefusion/global_resources/auth/auth_methods.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.background,
      child: ListView(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(),
            child: Column(
              children: [
                Image.asset(Constants.logoPath, height: 80),
                const Text(
                  'CodeFusion',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            title: const Text('Home'),
            leading: const Icon(Icons.home),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/main-home');
            },
          ),
          ListTile(
            title: Text('Profile'),
            leading: Icon(Icons.person),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profile');
            },
          ),
          ListTile(
            title: const Text('CodeMate'),
            leading: const Icon(Icons.smart_toy_outlined),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/chat-bot');
            },
          ),
          ListTile(
            title: const Text('Ques & Ans'),
            leading: const Icon(Icons.forum_outlined),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/que-answer');
            },
          ),
          ListTile(
            title: const Text('Meet & Chat'),
            leading: const Icon(Icons.group),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/meet-home');
            },
          ),
          ListTile(
            title: const Text('Mentorship'),
            leading: const Icon(Icons.school_rounded),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/mentor-list-screen');
            },
          ),
          ListTile(
            title: const Text('Resources'),
            leading: const Icon(Icons.menu_book_rounded),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/resources');
            },
          ),
          ListTile(
            title: const Text('Resume'),
            leading: const Icon(Icons.book_outlined),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/resume');
            },
          ),
          // ListTile(
          //   title: const Text('Job Form'),
          //   leading: const Icon(Icons.file_copy_rounded),
          //   onTap: () {
          //     Navigator.pop(context);
          //     Navigator.pushNamed(context, '/job-form');
          //   },
          // ),
          ListTile(
            title: const Text('Job Recommendations'),
            leading: const Icon(Icons.business_center_rounded),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/job-recommend');
            },
          ),
          ListTile(
            title: Text('Settings'),
            leading: Icon(Icons.settings),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
          ),
          ListTile(
            title: const Text('Logout'),
            leading: const Icon(Icons.logout),
            onTap: () async {
              await AuthMethods().signOut();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
    );
  }
}
