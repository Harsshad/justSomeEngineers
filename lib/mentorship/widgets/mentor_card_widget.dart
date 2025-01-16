import 'package:flutter/material.dart';
import 'package:codefusion/mentorship/screens/mentor_detail_screen.dart';
import 'package:codefusion/profile%20&%20Q&A/core/constants/constants.dart';

class MentorCardWidget extends StatelessWidget {
  final Map<String, dynamic> mentor;
  final String mentorId;
  final VoidCallback onTap;  // Add onTap callback

  const MentorCardWidget({
    Key? key,
    required this.mentor,
    required this.mentorId,
    required this.onTap,  // Pass onTap to the constructor
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: mentor['profileImage'] != null
              ? NetworkImage(mentor['profileImage'])
              : const AssetImage(Constants.default_profile) as ImageProvider,
        ),
        title: Text(mentor['fullName'] ?? 'N/A', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(mentor['role'] ?? 'N/A', style: TextStyle(color: Colors.grey[600])),
            Text('\$${mentor['hourlyRate'] ?? '0'}/hour'),
            Text(
              mentor['bio'] ?? 'No description available',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: onTap,  // Use the passed onTap function
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          ),
          child: const Text('View Profile'),
        ),
      ),
    );
  }
}
