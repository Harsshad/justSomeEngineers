import 'package:codefusion/profile%20&%20Q&A/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:codefusion/global_resources/auth/auth_methods.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      backgroundColor: theme.colorScheme.background,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(),
                child: Column(
                  children: [
                    Image.asset(Constants.logoPath, height: 100),
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
                title: const Text(
                  'Home',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                leading: const Icon(Icons.home),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/main-home');
                },
              ),
              ListTile(
                title: const Text(
                  'Profile',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                leading: const Icon(Icons.person),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/profile');
                },
              ),
              if (kIsWeb ||
                  Platform.isMacOS ||
                  Platform.isWindows ||
                  Platform.isLinux)
                ListTile(
                  title: const Text(
                    'CodeMate',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  leading: const Icon(Icons.smart_toy_outlined),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/chat-bot');
                  },
                ),
              ListTile(
                title: const Text(
                  'Ques & Ans',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                leading: const Icon(Icons.forum_outlined),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/que-answer');
                },
              ),
              if (!kIsWeb && (Platform.isAndroid || Platform.isIOS))
                ListTile(
                  title: const Text(
                    'Meet & Chat',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  leading: const Icon(Icons.group),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/meet-home');
                  },
                ),
              ListTile(
                title: const Text(
                  'Mentorship',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                leading: const Icon(Icons.school_rounded),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/mentor-list-screen');
                },
              ),
              ListTile(
                title: const Text(
                  'Resources',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                leading: const Icon(Icons.menu_book_rounded),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/resource_hub');
                },
              ),
              ListTile(
                title: const Text(
                  'Resume',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                leading: const Icon(Icons.book_outlined),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/resume');
                },
              ),
              ListTile(
                title: const Text(
                  'Job Recommendations',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                leading: const Icon(Icons.business_center_rounded),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/job-recommend');
                },
              ),
              ListTile(
                title: const Text(
                  'Settings',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                leading: const Icon(Icons.settings),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/settings');
                },
              ),
            ],
          ),
          ListTile(
            title: const Text(
              'Logout',
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
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
