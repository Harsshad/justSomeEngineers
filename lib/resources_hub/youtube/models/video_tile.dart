import 'package:codefusion/resources_hub/youtube/models/video_model.dart';
import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';  //Target of URI doesn't exist: 'package:intl/intl.dart'.
// Try creating the file referenced by the URI, or try using a URI for a file that does exist.

class VideoTile extends StatelessWidget {
  final Video video;

  const VideoTile({Key? key, required this.video}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final formattedDate = DateFormat('yMMMd').format(video.publishedAt);  //The method 'DateFormat' isn't defined for the type 'VideoTile'.
// Try correcting the name to the name of an existing method, or defining a method named 'DateFormat'.
//The getter 'publishedAt' isn't defined for the type 'Video'.
// Try importing the library that defines 'publishedAt', correcting the name to the name of an existing getter, or defining a getter or field named 'publishedAt'.

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Image.network(video.thumbnailUrl, width: 100, fit: BoxFit.cover),
        title: Text(video.title, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(video.channelTitle, style: TextStyle(fontWeight: FontWeight.w600)),
            // Text("⏱ ${video.duration} • 👍 ${video.likeCount} • 📅 $formattedDate"),
          ],
        ),
        onTap: () {
          // Navigate to video screen
        },
      ),
    );
  }
}
