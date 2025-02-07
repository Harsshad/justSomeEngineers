import 'package:codefusion/Q&A/screen/q&a_screen.dart';
import 'package:codefusion/User%20Profile/user_profile.dart';
import 'package:codefusion/dev_talk/screen/search_screen.dart';
import 'package:codefusion/screens/developer_screen.dart';
import 'package:codefusion/screens/temp_job_screen.dart';
import 'package:flutter/material.dart';
import 'package:codefusion/chat_bot/pages/home_page.dart';
import 'package:codefusion/global_resources/auth/auth_gate.dart';
import 'package:codefusion/job%20board/screens/job_list_screen.dart';
import 'package:codefusion/job%20board/screens/job_preference_form.dart';
import 'package:codefusion/meet%20&%20chat/screens/video_call_screen.dart';
import 'package:codefusion/mentorship/screens/mentor_list_screen.dart';
import 'package:codefusion/mentorship/screens/mentor_detail_screen.dart';
import 'package:codefusion/mentorship/screens/mentor_form.dart';
import 'package:codefusion/mentorship/screens/mentor_login_screen.dart';
import 'package:codefusion/mentorship/screens/mentor_register_screen.dart';
import 'package:codefusion/resources_hub/screens/resources_page.dart';
import 'package:codefusion/resume/page/resume_input_page.dart';
import 'package:codefusion/User%20Profile/profile_screen.dart';
import 'package:codefusion/screens/resources_screen.dart';
import 'package:codefusion/screens/settings_screen.dart';
import 'package:codefusion/screens/main_home_screen.dart';
import 'package:codefusion/screens/ques_ans_screen.dart';
import 'package:codefusion/meet%20&%20chat/screens/home_screen.dart';

Map<String, WidgetBuilder> getAppRoutes() {
  return {
    '/login': (context) => const AuthGate(),
    '/meet-home': (context) => const HomeScreen(),
    '/video-call': (context) => const VideoCallScreen(),
    '/main-home': (context) => const MainHomeScreen(),
    '/job-form': (context) => JobPreferenceForm(),
    '/job-recommend': (context) => JobListScreen(),
    '/resources': (context) => const ResourcesScreen(),
    '/mentor-form-widget': (context) => MentorForms(),
    '/mentor-list-screen': (context) => const MentorListScreens(),
    '/mentor_details': (context) {
      final mentorId = ModalRoute.of(context)?.settings.arguments as String?;
      if (mentorId == null) {
        return const Center(child: Text("Error: Mentor ID is missing."));
      }
      return MentorDetailsScreen(mentorId: mentorId);
    },
    '/mentor_login': (context) => MentorLoginScreen(onTap: () {}),
    '/mentor_register': (context) => MentorRegisterScreen(onTap: () {}),
    '/que-answer': (context) => const QuesAnsScreen(),
    '/settings': (context) => const SettingsScreen(),
    '/profile': (context) => const ProfileScreen(),
    '/chat-bot': (context) => const BotHomePage(),
    '/resume': (context) => const ResumeInputPage(),
    '/resource_hub': (context) => const ResourcesPage(),
    '/developer-screen': (context) => const DeveloperScreen(),
    '/dev-talk': (context) => const SearchScreen(),
    '/que-ans': (context) => QAScreen(),
    '/temp-job-screen': (context) => const TempJobScreen(),
    '/user-profile': (context) => const UserProfile(),
    
    // '/que-ans': (context) =>   QuestionListScreen(),
  };
}
