export 'video_screen_stub.dart'
    if (dart.library.html) 'video_screen_web.dart'
    if (dart.library.io) 'video_screen_mobile.dart';
