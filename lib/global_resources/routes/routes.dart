import 'package:codefusion/Q&A/screen/q&a_screen.dart';
import 'package:codefusion/User%20Profile/screens/user_profile_form.dart';
import 'package:codefusion/User%20Profile/screens/user_profile.dart';
import 'package:codefusion/code_mate/pages/chat_page.dart';
// import 'package:codefusion/chat_bot/pages/chat_page.dart';
import 'package:codefusion/dev_chat/pages/chat_list_screen.dart';
import 'package:codefusion/dev_chat/pages/user_chat_page.dart';
import 'package:codefusion/mentorship/screens/applied_mentors_screen.dart';
import 'package:codefusion/mentorship/screens/mentee_requests_screen.dart';
import 'package:codefusion/mentorship/screens/mentees_list_screen.dart';
import 'package:codefusion/mentorship/screens/mentor_profile_page.dart';
import 'package:codefusion/resources_hub/youtube/screens/youtube_home_screen.dart';
import 'package:codefusion/screens/developer_screen.dart';
import 'package:codefusion/screens/onboarding_screen.dart';
import 'package:codefusion/screens/support_page.dart';
import 'package:codefusion/screens/temp_job_screen.dart';
import 'package:flutter/material.dart';
// import 'package:codefusion/chat_bot/pages/home_page.dart';
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
import 'package:codefusion/screens/settings_screen.dart';
import 'package:codefusion/screens/main_home_screen.dart';
// import 'package:codefusion/screens/ques_ans_screen.dart';
import 'package:codefusion/meet%20&%20chat/screens/home_screen.dart';

Map<String, WidgetBuilder> getAppRoutes() {
  return {
    '/login': (context) => const AuthGate(),
    '/meet-home': (context) => const HomeScreen(),
    '/video-call': (context) => const VideoCallScreen(),
    '/main-home': (context) => const MainHomeScreen(),
    '/job-form': (context) => JobPreferenceForm(),
    '/job-recommend': (context) => JobListScreen(),
    '/mentor-form-widget': (context) => MentorForms(),
    '/mentor-profile': (context) => const MentorProfilePage(),
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
    '/applied-mentors': (context) => const AppliedMentorsScreen(),
    '/mentee-requests': (context) => const MenteeRequestsScreen(),
    '/mentees-list': (context) => const MenteesListScreen(),
    // other routes...
    // '/que-answer': (context) => const QuesAnsScreen(),
    '/settings': (context) => const SettingsScreen(),
    // '/chat-bot': (context) => const BotHomePage(),
    // '/chat-bot': (context) => const ChatPage(),
    '/chat-bot': (context) =>  BotChatScreen(),
    '/resume': (context) => const ResumeInputPage(),
    '/resource_hub': (context) => const ResourcesPage(),
    '/developer-screen': (context) => const DeveloperScreen(),
    // '/dev-talk': (context) => const SearchScreen(),
    '/que-ans': (context) => QAScreen(),
    '/temp-job-screen': (context) => const TempJobScreen(),
    '/user-profile': (context) => const UserProfile(),
    '/user-profile-form': (context) => const UserProfileForm(),
    '/user-chat-screen': (context) =>  ChatScreen(),
    '/youtube-home-screen': (context) =>  YoutubeHomeScreen(),
    '/support-page': (context) =>  SupportPage(),
    '/onboard-screen': (context) =>  OnboardingScreen(),


    
    // '/que-ans': (context) =>   QuestionListScreen(),
  };
}
