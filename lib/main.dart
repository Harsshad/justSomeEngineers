import 'package:codefusion/global_resources/auth/auth_gate.dart';
import 'package:codefusion/global_resources/auth/auth_methods.dart';
import 'package:codefusion/global_resources/routes/routes.dart';
import 'package:codefusion/global_resources/themes/theme_provider.dart';
import 'package:codefusion/screens/main_home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
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
      routes: getAppRoutes(),
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