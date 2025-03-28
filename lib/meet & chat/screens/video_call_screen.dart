import 'package:codefusion/global_resources/auth/auth_methods.dart';
import 'package:codefusion/meet%20&%20chat/resources/jitsi_meet_wrapper_method.dart';
import 'package:codefusion/meet%20&%20chat/widgets/meeting_option.dart';

import 'package:flutter/material.dart';
import 'package:jitsi_meet_wrapper/jitsi_meet_wrapper.dart';






class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({Key? key}) : super(key: key);

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final AuthMethods _authMethods = AuthMethods();

  late TextEditingController meetingIdController;
  late TextEditingController nameController;

  bool isAudioMuted = true;
  bool isVideoMuted = true;

  @override
  void initState() {
    meetingIdController = TextEditingController();
    nameController = TextEditingController(text: _authMethods.user.displayName);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    meetingIdController.dispose();
    nameController.dispose();
  }

  _joinMeeting() {
  //how can I call here join meeting method from jitsi_meet_wrapper_method.dart
  
  

    JitsiMeetMethod().createMeeting(
      roomName: meetingIdController.text,
      isAudioMuted: isAudioMuted,
      isVideoMuted: isVideoMuted,
      username: nameController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text(
          'Join Meeting',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 60,
            child: TextField(
              controller: meetingIdController,
              maxLines: 1,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                fillColor: Theme.of(context).colorScheme.secondary,
                filled: true,
                border: InputBorder.none,
                hintText: 'Room ID',
                contentPadding: EdgeInsets.fromLTRB(16, 8, 0, 0),
              ),
            ),
          ),
          SizedBox(
            height: 60,
            child: TextField(
              controller: nameController,
              maxLines: 1,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.text,
              decoration:  InputDecoration(
                fillColor: Theme.of(context).colorScheme.secondary,
                filled: true,
                border: InputBorder.none,
                hintText: 'Name',
                contentPadding: EdgeInsets.fromLTRB(16, 8, 0, 0),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          InkWell(
            splashColor:  Theme.of(context).colorScheme.primary,
            onTap: _joinMeeting,
            child: const Padding(
              padding: EdgeInsets.all(10),
              //adding color to inkwell
              
              child: Text(
                'Join',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          MeetingOption(
            text: 'Mute Audio',
            isMute: isAudioMuted,
            onChange: (value) => onAudioMuted(value),
          ),
          const SizedBox(
            height: 20,
          ),
          MeetingOption(
            text: 'Turn off My video',
            isMute: isVideoMuted,
            onChange: (value) => onVideoMuted(value),
          ),
        ],
      ),
    );
  }

  onAudioMuted(bool? value) {
    setState(() {
      isAudioMuted = value!;
    });
  }

  onVideoMuted(bool? value) {
    setState(() {
      isVideoMuted = value!;
    });
  }
}
