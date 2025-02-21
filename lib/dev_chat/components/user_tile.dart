import 'package:codefusion/global_resources/constants/constants.dart';
import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  final String text;
  final String profileImage;
  final void Function()? onTap;

  const UserTile({
    super.key,
    required this.text,
    required this.onTap,
    required this.profileImage,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
          decoration: BoxDecoration(
            // color: Colors.transparent,
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(
            vertical: 5,
            horizontal: 25,
          ),
          padding: const EdgeInsets.all(18),
          child: Row(
          children: [
            // Profile Image
            CircleAvatar(
              radius: 20, // Adjust the size as needed
              backgroundColor: Colors.grey.shade800,
              backgroundImage: profileImage.isNotEmpty
                  ? NetworkImage(profileImage)
                  : const AssetImage(Constants.default_profile)
                      as ImageProvider,
            ),

            const SizedBox(width: 20),

            // Username
            Text(text),
          ],
        ),
      ),
    );
  }
}
