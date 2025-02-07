import 'package:codefusion/global_resources/constants/constants.dart';
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
          Expanded(
            child: SingleChildScrollView(
              child: Column(
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
                  GestureDetector(
                    onDoubleTap: () => Navigator.pushNamed(context, '/developer-screen'),
                    child: ListTile(
                      title: const Text('Home'),
                      leading: const Icon(Icons.home),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/main-home');
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text('Profile'),
                    leading: const Icon(Icons.person),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/user-profile');
                      // Navigator.pushNamed(context, '/profile');
                    },
                  ),
                  if (kIsWeb || Platform.isMacOS || Platform.isWindows || Platform.isLinux)
                    ListTile(
                      title: const Text('CodeMate'),
                      leading: const Icon(Icons.smart_toy_outlined),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/chat-bot');
                      },
                    ),
                  ListTile(
                    title: const Text('CodeQuery'),
                    leading: const Icon(Icons.chat_rounded),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/que-ans');
                    },
                  ),
                  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS))
                    ListTile(
                      title: const Text('FusionMeet'),
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
                      Navigator.pushNamed(context, '/resource_hub');
                    },
                  ),
                  // ListTile(
                  //   title: const Text('Dev Chat'),
                  //   // title: const Text('Dev Talk (still need to work on it a lot)'),
                  //   leading: const Icon(Icons.forum_outlined),
                  //   onTap: () {
                  //     Navigator.pop(context);
                  //     Navigator.pushNamed(context, '/dev-talk');
                  //   },
                  // ),
                  ListTile(
                    title: const Text('Resume'),
                    leading: const Icon(Icons.book_outlined),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/resume');
                    },
                  ),
                  GestureDetector(
                    onDoubleTap: () => Navigator.pushNamed(context, '/job-recommend'),
                    child: ListTile(
                      title: const Text('Job Board'),
                      leading: const Icon(Icons.business_center_rounded),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/temp-job-screen');
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text('Settings'),
                    leading: const Icon(Icons.settings),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/settings');
                    },
                  ),
                ],
              ),
            ),
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