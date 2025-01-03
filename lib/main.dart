import 'package:codefusion/resources/auth_methods.dart';
import 'package:codefusion/screens/home_screen.dart';
import 'package:codefusion/screens/login_screen.dart';
import 'package:codefusion/screens/video_call_screen.dart';
import 'package:codefusion/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CodeFusion',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: backgroundColor
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home':(context)=>const HomeScreen(),
        '/video-call': (context)=> const VideoCallScreen(),
      },
      home: StreamBuilder(
        stream: AuthMethods().authChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (snapshot.hasData) {
            return const HomeScreen();
          } else if (snapshot.hasError) {
            return const Scaffold(
              body: Center(
                child: Text('Something went wrong'),
              ),
            );
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}