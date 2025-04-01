import 'package:codefusion/global_resources/constants/constants.dart';
import 'package:flutter/material.dart';

class ArticleMentorCard extends StatelessWidget {
  final Map<String, dynamic> mentor;
  final String mentorId;
  final VoidCallback onTap;

  const ArticleMentorCard({
    Key? key,
    required this.mentor,
    required this.mentorId,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: mentor['profileImage'] != null && mentor['profileImage'].isNotEmpty
                  ? Image.network(
                      mentor['profileImage'],
                      width: 120,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      Constants.default_profile,
                      width: 120,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mentor['fullName'] ?? 'N/A',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      mentor['expertise'] ?? 'N/A',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${mentor['monthlyRate'] ?? '0'}/month',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      mentor['bio'] ?? 'No description available',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}