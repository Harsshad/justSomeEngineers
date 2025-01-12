import 'package:codefusion/Mentorship/screens/video_call_screen.dart';
import 'package:codefusion/chat_bot/pages/home_page.dart';
import 'package:codefusion/job%20board/screens/job_list_screen.dart';
import 'package:codefusion/job%20board/screens/job_preference_form.dart';
import 'package:codefusion/mentorship/screens/mentorship_screen.dart';
import 'package:codefusion/mentorship/utils/colors.dart';
import 'package:codefusion/resume/page/resume_input_page.dart';
import 'package:codefusion/screens/profile_screen.dart';
import 'package:codefusion/screens/resources_screen.dart';
import 'package:codefusion/screens/settings_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'resources/auth_methods.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_home_screen.dart';
import 'screens/ques_ans_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CodeFusion',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: backgroundColor,
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/meet-home': (context) => const HomeScreen(),
        '/video-call': (context) => const VideoCallScreen(),
        '/main-home': (context) => const MainHomeScreen(),
        '/job-form': (context) => JobPreferenceForm(),
        '/job-recommend': (context) => JobListScreen(),
        '/resources': (context) => const ResourcesScreen(),
        '/mentorship': (context) => const MentorshipScreen(),
        '/que-answer': (context) => const QuesAnsScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/chat-bot': (context) => const BotHomePage(),
        '/resume': (context) =>  ResumeInputPage(),
      },
      home: StreamBuilder(
        stream: AuthMethods().authChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Skeletonizer(
                enabled: true,
                child: Text(
                  "Loading data...",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            );
          }

          if (snapshot.hasData) {
            return const MainHomeScreen();
          }

          if (!snapshot.hasData) {
            return const LoginScreen();
            // return const MainHomeScreen();
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          return const MainHomeScreen();
        },
      ),
    );
  }
}
