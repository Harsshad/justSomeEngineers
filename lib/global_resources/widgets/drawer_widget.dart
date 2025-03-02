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
                        Image.asset(
                          Constants.logoPath,
                          height: 100,
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                        Text(
                          'CodeFusion',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.inversePrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onDoubleTap: () =>
                        Navigator.pushNamed(context, '/developer-screen'),
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
                      if (isMentor) {
                        Navigator.pushNamed(context,
                            '/mentor-profile'); // add a back button that takes back to the home page in the once entered the mentor profile or user profile
                      } else {
                        Navigator.pushNamed(context, '/user-profile');
                      }
                    },
                  ),
                  // if (kIsWeb ||
                  //     Platform.isMacOS ||
                  //     Platform.isWindows ||
                  //     Platform.isLinux)
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
                    leading: Image.asset(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      Constants.codequery,
                      scale: 17,
                    ),
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
                    title: const Text('Dev Guru'),
                    leading: const Icon(Icons.school_rounded),
                    trailing: DropdownButtonHideUnderline(
                      child: DropdownButton2<String>(
                        customButton: const Icon(Icons.arrow_drop_down),
                        items: (isMentor
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
                                    style:  TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.inversePrimary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                        onChanged: (String? value) {
                          setState(() {
                            selectedMentorshipOption = value;
                          });
                          Navigator.pop(context);
                          switch (value) {
                            case 'Mentors List':
                              Navigator.pushNamed(context, '/mentor-list-screen');
                              break;
                            case 'Mentee Requests':
                              Navigator.pushNamed(context, '/mentee-requests');
                              break;
                            case 'My Mentees':
                              Navigator.pushNamed(context, '/mentees-list');
                              break;
                            case 'Applied Mentors':
                              Navigator.pushNamed(context, '/applied-mentors');
                              break;
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
                            color: theme.colorScheme.background,
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
                            color: theme.colorScheme.background,
                          ),
                          offset: const Offset(-20, 0),
                          scrollbarTheme: ScrollbarThemeData(
                            radius: const Radius.circular(40),
                            thickness: WidgetStateProperty.all<double>(6),
                            thumbVisibility: WidgetStateProperty.all<bool>(true),
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
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/resource_hub');
                    },
                  ),
                  ListTile(
                    title: const Text('Dev Chat'),
                    leading: const Icon(Icons.forum_outlined),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/user-chat-screen');
                    },
                  ),
                  ListTile(
                    title: const Text('Resume Gen'),
                    leading: const Icon(Icons.book_outlined),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/resume');
                    },
                  ),
                  GestureDetector(
                    onDoubleTap: () =>
                        Navigator.pushNamed(context, '/job-recommend'),
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