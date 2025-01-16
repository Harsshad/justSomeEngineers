import 'package:codefusion/chat_bot/pages/home_page.dart';
import 'package:codefusion/global_resources/auth/auth_gate.dart';
import 'package:codefusion/global_resources/auth/auth_methods.dart';
import 'package:codefusion/global_resources/themes/theme_provider.dart';
import 'package:codefusion/job%20board/screens/job_list_screen.dart';
import 'package:codefusion/job%20board/screens/job_preference_form.dart';
import 'package:codefusion/meet%20&%20chat/screens/video_call_screen.dart';
import 'package:codefusion/mentorship/screens/mentor_list_screen.dart';
import 'package:codefusion/mentorship/screens/mentor_detail_screen.dart';
import 'package:codefusion/mentorship/screens/mentor_form_widget.dart';
import 'package:codefusion/mentorship/screens/mentor_login_screen.dart';
import 'package:codefusion/mentorship/screens/mentor_register_screen.dart';
import 'package:codefusion/resume/page/resume_input_page.dart';
import 'package:codefusion/screens/profile_screen.dart';
import 'package:codefusion/screens/resources_screen.dart';
import 'package:codefusion/screens/settings_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'meet & chat/screens/home_screen.dart';
import 'screens/main_home_screen.dart';
import 'screens/ques_ans_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CodeFusion',
      theme: Provider.of<ThemeProvider>(context).themeData,
      // theme: ThemeData.dark().copyWith(
      //   scaffoldBackgroundColor: backgroundColor,
      // ),
      routes: {
        '/login': (context) => const AuthGate(),
        '/meet-home': (context) => const HomeScreen(),
        '/video-call': (context) => const VideoCallScreen(),
        '/main-home': (context) => const MainHomeScreen(),
        '/job-form': (context) => JobPreferenceForm(),
        '/job-recommend': (context) => JobListScreen(),
        '/resources': (context) => const ResourcesScreen(),
        '/mentor-form-widget': (context) => MentorForms(),
        '/mentor-list-screen': (context) => MentorListScreens(),
        '/mentor_details': (context) {
          final mentorId =
              ModalRoute.of(context)?.settings.arguments as String?;

          // Handle the case where mentorId might be null
          if (mentorId == null) {
            return const Center(child: Text("Error: Mentor ID is missing."));
          }

          return MentorDetailsScreen(mentorId: mentorId);
        },
        '/mentor_login': (context) => MentorLoginScreen(
              onTap: () {},
            ),
        '/mentor_register': (context) => MentorRegisterScreen(
              onTap: () {},
            ),
        '/que-answer': (context) => const QuesAnsScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/chat-bot': (context) => const BotHomePage(),
        '/resume': (context) => ResumeInputPage(),
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
            return const AuthGate();
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
