import 'package:codefusion/global_resources/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:codefusion/global_resources/components/animated_shadow_button.dart';

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
    final String? profileImage = widget.mentor['profileImage'];

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.blueGrey[100],
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      (profileImage != null && profileImage.isNotEmpty)
                          ? NetworkImage(profileImage)
                          : const AssetImage(Constants.default_profile)
                              as ImageProvider,
                  onBackgroundImageError: (_, __) {
                    // Handle image loading errors
                    debugPrint('Failed to load profile image');
                  },
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.mentor['fullName'] ?? 'N/A',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87),
                      ),
                      Text(
                        widget.mentor['expertise'] ?? 'N/A',
                        style: const TextStyle(
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        '\$${widget.mentor['monthlyRate'] ?? '0'}/month',
                        style: const TextStyle(
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.mentor['bio'] ?? 'No description available',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.bottomRight,
              child: isHovered
                  ? AnimatedShadowButton(
                      onPressed: widget.onTap,
                      text: 'View Profile',
                    )
                  : ElevatedButton(
                      onPressed: widget.onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
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
          ],
        ),
      ),
    );
  }
}
