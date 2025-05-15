import 'dart:io' show Platform;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codefusion/global_resources/auth/auth_methods.dart';
import 'package:codefusion/global_resources/constants/constants.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({Key? key}) : super(key: key);

  @override
  _DrawerWidgetState createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  bool isMentor = false;
  String? selectedMentorshipOption;

  String _currentPage = '/main-home';

  @override
  void initState() {
    super.initState();
    _checkIfUserIsMentor();
  }

  Future<void> _checkIfUserIsMentor() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection("mentors")
          .doc(currentUser.uid)
          .get();
      if (userDoc.exists) {
        setState(() {
          isMentor = true;
        });
      }
    }
  }

  void navigateToPage(String routeName) {
    setState(() {
      _currentPage = routeName;
    });
    Navigator.pop(context);
    Navigator.pushNamed(context, routeName);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      backgroundColor: theme.drawerTheme.backgroundColor,
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
                        Image.asset(
                          Constants.logoPath,
                          height: 100,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        Text(
                          'CodeFusion',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onDoubleTap: () =>
                        Navigator.pushNamed(context, '/support-page'),
                        // Navigator.pushNamed(context, '/developer-screen'),
                    child: ListTile(
                      title: const Text('Home'),
                      leading: const Icon(Icons.home),
                      tileColor: _currentPage == '/main-home'
                          ? theme.colorScheme.primary.withOpacity(0.1)
                          : null,
                      onTap: () {
                        navigateToPage('/main-home');
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text('Profile'),
                    leading: const Icon(Icons.person),
                    tileColor: _currentPage == '/mentor-profile' ||
                            _currentPage == '/user-profile'
                        ? theme.colorScheme.primary.withOpacity(0.1)
                        : null,
                    onTap: () {
                      if (isMentor) {
                        navigateToPage('/mentor-profile');
                      } else {
                        navigateToPage('/user-profile');
                      }
                    },
                  ),
                  // GestureDetector(
                  //   onDoubleTap: () =>
                  //       Navigator.pushNamed(context, '/chat-bot'),
                  //   child: 
                    ListTile(
                      title: const Text('CodeMate'),
                      leading: const Icon(Icons.smart_toy_outlined),
                      tileColor: _currentPage == '/chat-bot'
                        ? theme.colorScheme.primary.withOpacity(0.1)
                        : null,
                    onTap: () {
                      navigateToPage('/chat-bot');
                    },
                      // tileColor: _currentPage == '/temp-job-screen'
                      //     ? theme.colorScheme.primary.withOpacity(0.1)
                      //     : null,
                      // onTap: () {
                      //   navigateToPage('/temp-job-screen');
                      // },
                    // ),
                  ),
                  ListTile(
                    title: const Text('CodeQuery'),
                    leading: Image.asset(
                      color: Theme.of(context).colorScheme.secondary,
                      Constants.codequery,
                      scale: 17,
                    ),
                    tileColor: _currentPage == '/que-ans'
                        ? theme.colorScheme.primary.withOpacity(0.1)
                        : null,
                    onTap: () {
                      navigateToPage('/que-ans');
                    },
                  ),
                  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS))
                    ListTile(
                      title: const Text('FusionMeet'),
                      leading: const Icon(Icons.group),
                      tileColor: _currentPage == '/meet-home'
                          ? theme.colorScheme.primary.withOpacity(0.1)
                          : null,
                      onTap: () {
                        navigateToPage('/meet-home');
                      },
                    ),
                  ListTile(
                    title: const Text('Dev Guru'),
                    leading: const Icon(Icons.school_rounded),
                    trailing: DropdownButtonHideUnderline(
                      child: DropdownButton2<String>(
                        customButton: const Icon(Icons.arrow_drop_down),
                        items: (isMentor  //how can I change the color of the drop down list
                                ? [
                                    'Mentors List',
                                    'Mentee Requests',
                                    'My Mentees',
                                    'Applied Mentors'
                                  ]
                                : ['Mentors List', 'Applied Mentors'])
                            .map((String item) => DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(
                                    item,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode ? Colors.white : const Color(0xFF2A2824),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                        onChanged: (String? value) {
                          if (value != null) {
                            setState(() {
                              selectedMentorshipOption = value;
                            });

                            // ✅ Close the drawer before navigating
                            // Navigator.pop(context);

                            // ✅ Add a delay to prevent navigator lock issue
                            Future.delayed(const Duration(milliseconds: 300),
                                () {
                              if (mounted) {
                                switch (value) {
                                  case 'Mentors List':
                                    Navigator.pushNamed(
                                        context, '/mentor-list-screen');
                                    break;
                                  case 'Mentee Requests':
                                    Navigator.pushNamed(
                                        context, '/mentee-requests');
                                    break;
                                  case 'My Mentees':
                                    Navigator.pushNamed(
                                        context, '/mentees-list');
                                    break;
                                  case 'Applied Mentors':
                                    Navigator.pushNamed(
                                        context, '/applied-mentors');
                                    break;
                                }
                              }
                            });
                          }
                        },
                        buttonStyleData: ButtonStyleData(
                          height: 50,
                          width: 50,
                          padding: const EdgeInsets.only(left: 14, right: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.black26,
                            ),
                            color: Theme.of(context).colorScheme.background,
                          ),
                          elevation: 2,
                        ),
                        iconStyleData: const IconStyleData(
                          icon: Icon(
                            Icons.arrow_drop_down,
                          ),
                          iconSize: 24,
                          iconEnabledColor: Colors.black,
                          iconDisabledColor: Colors.grey,
                        ),
                        dropdownStyleData: DropdownStyleData(
                          maxHeight: 200,
                          width: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: Theme.of(context).colorScheme.background,
                          ),
                          offset: const Offset(-20, 0),
                          scrollbarTheme: ScrollbarThemeData(
                            radius: const Radius.circular(40),
                            thickness: WidgetStateProperty.all<double>(6),
                            thumbVisibility:
                                WidgetStateProperty.all<bool>(true),
                          ),
                        ),
                        menuItemStyleData: const MenuItemStyleData(
                          height: 40,
                          padding: EdgeInsets.only(left: 14, right: 14),
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                    title: const Text('Resources'),
                    leading: const Icon(Icons.menu_book_rounded),
                    tileColor: _currentPage == '/resource_hub'
                        ? theme.colorScheme.primary.withValues()
                        : null,
                    onTap: () {
                      navigateToPage('/resource_hub');
                    },
                  ),
                  ListTile(
                    title: const Text('Dev Chat'),
                    leading: const Icon(Icons.forum_outlined),
                    tileColor: _currentPage == '/user-chat-screen'
                        ? theme.colorScheme.primary.withOpacity(0.1)
                        : null,
                    onTap: () {
                      navigateToPage('/user-chat-screen');
                    },
                  ),
                  ListTile(
                    title: const Text('Resume Gen'),
                    leading: const Icon(Icons.book_outlined),
                    tileColor: _currentPage == '/resume'
                        ? theme.colorScheme.primary.withOpacity(0.1)
                        : null,
                    onTap: () {
                      navigateToPage('/resume');
                    },
                  ),
                  // GestureDetector(
                  //   onDoubleTap: () =>
                  //       Navigator.pushNamed(context, '/job-recommend'),
                  //   child: 
                    ListTile(
                      title: const Text('Job Board'),
                      leading: const Icon(Icons.business_center_rounded),
                      tileColor: _currentPage == '/job-recommend'
                        ? theme.colorScheme.primary.withOpacity(0.1)
                        : null,
                    onTap: () {
                      navigateToPage('/job-recommend');
                    },
                      // tileColor: _currentPage == '/temp-job-screen'
                      //     ? theme.colorScheme.primary.withOpacity(0.1)
                      //     : null,
                      // onTap: () {
                      //   navigateToPage('/temp-job-screen');
                      // },
                    // ),
                  ),
                  // ListTile(
                  //   title: const Text('Youtube'),
                  //   leading: const Icon(Icons.settings),
                  //   tileColor: _currentPage == '/youtube-home-screen'
                  //       ? theme.colorScheme.primary.withOpacity(0.1)
                  //       : null,
                  //   onTap: () {
                  //     navigateToPage('/youtube-home-screen');
                  //   },
                  // ),
                  GestureDetector(
                    onDoubleTap: () =>
                        Navigator.pushNamed(context, '/developer-screen'),
                        // Navigator.pushNamed(context, '/developer-screen'),
                    child: ListTile(
                    title: const Text('Settings'),
                    leading: const Icon(Icons.settings),
                    tileColor: _currentPage == '/settings'
                        ? theme.colorScheme.primary.withOpacity(0.1)
                        : null,
                    onTap: () {
                      navigateToPage('/settings');
                    },
                  ),
                  ),
                  ListTile(
                    title: const Text('Intro Screen'),
                    leading: const Icon(Icons.interests_rounded),
                    tileColor: _currentPage == '/onboard-screen'
                        ? theme.colorScheme.primary.withOpacity(0.1)
                        : null,
                    onTap: () {
                      navigateToPage('/onboard-screen');
                    },
                  ),
                  ListTile(
                    title: const Text('Dev Support'),
                    leading: const Icon(Icons.code),
                    tileColor: _currentPage == '/support-page'
                        ? theme.colorScheme.primary.withOpacity(0.1)
                        : null,
                    onTap: () {
                      navigateToPage('/support-page');
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
