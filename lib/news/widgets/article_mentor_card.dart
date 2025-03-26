import 'package:codefusion/global_resources/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    final double cardHeight = MediaQuery.of(context).size.height * 0.25; // Responsive height
    final double screenWidth = MediaQuery.of(context).size.width;

    // Dynamic label position based on screen size
    double labelLeft = screenWidth < 600 ? 12 : 220;
    double labelRight = screenWidth < 600 ? 12 : 220;  // Instead of left give this padding from right 

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            Container(
              height: cardHeight,
              child: Row(
                children: [
                  // Image Container with dynamic image loading
                  Expanded(
                    flex: 2,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                      child: _buildImage(mentor['profileImage']),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Mentor Info Section
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // const SizedBox(height: 25), // Add space for label
                          Text(
                            mentor['fullName'] ?? 'N/A',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            mentor['expertise'] ?? 'N/A',
                            style: const TextStyle(color: Colors.grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '\$${mentor['monthlyRate'] ?? '0'}/month',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // const Spacer(),
                          const SizedBox(height: 18),
                          Flexible(
                            child: Text(
                              mentor['bio'] ?? 'No description available',
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // "Mentor Available" label with dynamic positioning
            // Positioned(
            //   top: 8,
            //   right: labelRight,
            //   child: Container(
            //     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            //     decoration: BoxDecoration(
            //       color: Colors.blueAccent,
            //       borderRadius: BorderRadius.circular(8),
            //     ),
            //     child: const Text(
            //       'Mentor Available',
            //       style: TextStyle(
            //         color: Colors.white,
            //         fontWeight: FontWeight.bold,
            //         fontSize: 12,
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  /// ✅ Dynamic Image Loader for Web and Mobile
  Widget _buildImage(String? imagePath) {
    if (imagePath != null && imagePath.isNotEmpty) {
      if (imagePath.startsWith('http')) {
        // Network image for web or external URLs
        return Image.network(
          imagePath,
          fit: BoxFit.cover,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) => Image.asset(
            Constants.default_profile, // Fallback to local image on error
            fit: BoxFit.cover,
            height: double.infinity,
          ),
        );
      } else {
        // Local asset image (for default)
        return Image.asset(
          Constants.default_profile,
          fit: BoxFit.cover,
          height: double.infinity,
        );
      }
    } else {
      // Fallback in case of missing image path
      return Image.asset(
        Constants.default_profile,
        fit: BoxFit.cover,
        height: double.infinity,
      );
    }
  }
}
