import 'dart:math';

import 'package:codefusion/global_resources/auth/auth_methods.dart';
import 'package:codefusion/meet%20&%20chat/resources/jitsi_meet_wrapper_method.dart';
import 'package:codefusion/meet%20&%20chat/widgets/home_meeting_button.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jitsi_meet_wrapper/jitsi_meet_wrapper.dart';
import 'dart:core';

class MeetingScreen extends StatefulWidget {
  const MeetingScreen({Key? key}) : super(key: key);

  @override
  State<MeetingScreen> createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {
  final AuthMethods _authMethods = AuthMethods();
  final JitsiMeetMethod _jitsiMeetMethods = JitsiMeetMethod();

  createNewMeeting() async {
    var random = Random();
    String roomName = (random.nextInt(10000000) + 10000000).toString();
    _jitsiMeetMethods.createMeeting(
        roomName: roomName, isAudioMuted: true, isVideoMuted: true);
  }

  joinMeeting(BuildContext context) {
    Navigator.pushNamed(context, '/video-call');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            HomeMeetingButton(
              onPressed: () {
                createNewMeeting();
              },
              text: 'New Meeting',
              icon: Icons.videocam,
            ),
            HomeMeetingButton(
              onPressed: () => joinMeeting(context),
              text: 'Join Meeting',
              icon: Icons.add_box_rounded,
            ),
            HomeMeetingButton(
              onPressed: () {
                //show a calendar with current date
                showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
              }, //show a calendar with current date

              text: 'Calendar',
              icon: Icons.calendar_today,
            ),
            // HomeMeetingButton(
            //   onPressed: () {},
            //   text: 'Share Screen',
            //   icon: Icons.arrow_upward_rounded,
            // ),
          ],
        ),
        Expanded(
            child: Center(
          child: Text(
            'Create/Join Meeting with just a click',
            style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
        ))
      ],
    );
  }
}
