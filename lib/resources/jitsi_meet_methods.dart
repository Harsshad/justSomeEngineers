import 'package:codefusion/resources/auth_methods.dart';
import 'package:jitsi_meet_wrapper/jitsi_meet_wrapper.dart';

class JitsiMeetMethods {
  final AuthMethods _authMethods = AuthMethods();
  // Function to create a new meeting
  Future<void> createMeeting({
    required String roomName,
    required bool isAudioMuted,
    required bool isVideoMuted,
    String? userName,
    String? userEmail,
    String? avatarURL,
  }) async {
    try {
      // Configure meeting options
      var options = JitsiMeetingOptions(
        roomNameOrUrl: roomName,
        // subject: subject,
        userDisplayName: _authMethods.user.displayName,
        userEmail: _authMethods.user.email,
        userAvatarUrl: _authMethods.user.photoURL,
        isAudioMuted: false,
        isVideoMuted: false,
      );

      // Join meeting and set up event listeners
      await JitsiMeetWrapper.joinMeeting(
        options: options,
        listener: JitsiMeetingListener(
          onConferenceWillJoin: (url) {
            print("onConferenceWillJoin: url: $url");
          },
          onConferenceJoined: (url) {
            print("onConferenceJoined: url: $url");
          },
          onConferenceTerminated: (url, error) {
            print("onConferenceTerminated: url: $url, error: $error");
          },
        ),
      );
    } catch (e) {
      print("Error in createNewMeeting: ${e.toString()}");
    }
  }
}
