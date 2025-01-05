import 'package:codefusion/resources/firestore_methods.dart';
import 'package:flutter/cupertino.dart';
import 'package:jitsi_meet_wrapper/jitsi_meet_wrapper.dart';

import 'auth_methods.dart';

class JitsiMeetMethod {
  final AuthMethods _authMethods = AuthMethods();
  final FirestoreMethods _firestoreMethods = FirestoreMethods();

  final serverText = TextEditingController();
  final roomText = TextEditingController(text: "jitsi-meet-wrapper-test-room");
  final subjectText = TextEditingController(text: "My Plugin Test Meeting");
  final tokenText = TextEditingController();

  bool isAudioMuted = true;
  bool isAudioOnly = false;
  bool isVideoMuted = true;

  void createMeeting({
    required String roomName,
    required bool isAudioMuted,
    required bool isVideoMuted,
    String username = '',
  }) async {
    try {
      String? serverUrl =
          serverText.text.trim().isEmpty ? null : serverText.text;

      // Determine user display name
      String name;
      if (username.isEmpty) {
        name = _authMethods.user.displayName ?? 'Guest';
      } else {
        name = username;
      }

      // Define meeting options
      var options = JitsiMeetingOptions(
        roomNameOrUrl: roomText.text, // Use roomText for the room name
        serverUrl: serverUrl,
        subject: subjectText.text,
        token: tokenText.text,
        isAudioMuted: isAudioMuted,
        isAudioOnly: isAudioOnly,
        isVideoMuted: isVideoMuted,
        userDisplayName: name,
        userEmail: _authMethods.user.email,
      );

      // Start the meeting
      await JitsiMeetWrapper.joinMeeting(
        options: options,
        listener: JitsiMeetingListener(
          onOpened: () => debugPrint("onOpened"),
          onConferenceWillJoin: (url) =>
              debugPrint("onConferenceWillJoin: url: $url"),
          onConferenceJoined: (url) =>
              debugPrint("onConferenceJoined: url: $url"),
          onConferenceTerminated: (url, error) =>
              debugPrint("onConferenceTerminated: url: $url, error: $error"),
          onClosed: () => debugPrint("onClosed"),
        ),
      );

      // Add to meeting history
      await _firestoreMethods.addToMeetingHistory(roomName);
    } catch (error) {
      print("Error: $error");
    }
  }
}
