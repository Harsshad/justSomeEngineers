import 'package:codefusion/profile%20&%20Q&A/core/constants/constants.dart';
import 'package:flutter/material.dart';

class MentorCardWidget extends StatefulWidget {
  final Map<String, dynamic> mentor;
  final String mentorId;
  final VoidCallback onTap;

  const MentorCardWidget({
    Key? key,
    required this.mentor,
    required this.mentorId,
    required this.onTap,
  }) : super(key: key);

  @override
  _MentorCardWidgetState createState() => _MentorCardWidgetState();
}

class _MentorCardWidgetState extends State<MentorCardWidget> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            if (isHovered)
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 10.0,
                offset: const Offset(0, 5),
              )
            else
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 5.0,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: widget.mentor['profileImage'] != null
                ? NetworkImage(widget.mentor['profileImage'])
                : const AssetImage(Constants.default_profile) as ImageProvider,
          ),
          title: Text(
            widget.mentor['fullName'] ?? 'N/A',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.mentor['expertise'] ?? 'N/A',
                style: TextStyle(color: Colors.grey[600]),
              ),
              Text('\$${widget.mentor['monthlyRate'] ?? '0'}/month'),
              Text(
                widget.mentor['bio'] ?? 'No description available',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          trailing: ElevatedButton(
            onPressed: widget.onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: isHovered
                  ? const Color.fromARGB(255, 127, 72, 216).withOpacity(0.4)
                  : Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: Text(
              'View Profile',
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
