import 'package:flutter/material.dart';

class VideoScreen extends StatelessWidget {
  final String id;

  const VideoScreen({Key? key, required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Platform not supported")),
    );
  }
}
