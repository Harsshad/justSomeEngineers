import 'package:codefusion/chat_bot/pages/home_page.dart';
import 'package:codefusion/screens/job_preference_form.dart';
import 'package:codefusion/screens/profile_screen.dart';
import 'package:codefusion/screens/resources_screen.dart';
import 'package:codefusion/screens/settings_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'resources/auth_methods.dart';
import 'screens/home_screen.dart';
import 'screens/job_list_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_home_screen.dart';
import 'screens/mentorship_screen.dart';
import 'screens/ques_ans_screen.dart';
import 'screens/video_call_screen.dart';
import 'utils/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
        '/job-form': (context) =>  JobPreferenceForm(),
        '/job-recommend': (context) =>  JobListScreen(),
        // '/job-recommend': (context) {
        //   final arguments = ModalRoute.of(context)?.settings.arguments
        //       as Map<String, String>?;

        //   debugPrint('Arguments passed to /job-recommend: $arguments');

        //   if (arguments != null) {
        //     return JobListScreen(filters: arguments);
        //   } else {
        //     return JobListScreen(
        //         filters: {'category': 'General', 'location': 'Anywhere'});
        //   }
        // },
        '/resources': (context) => const ResourcesScreen(),
        '/mentorship': (context) => const MentorshipScreen(),
        '/que-answer': (context) => const QuesAnsScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/chat-bot': (context) => const BotHomePage() ,
      },
      home: StreamBuilder(
        stream: AuthMethods().authChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasData) {
            // return const HomeScreen();
            return const MainHomeScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
