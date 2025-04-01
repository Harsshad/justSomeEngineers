import 'package:flutter/material.dart';

class ProfileImageSection extends StatelessWidget {
  const ProfileImageSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: () {
            // Add logic to pick background banner image
          },
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[300],
            ),
            child: const Icon(
              Icons.add_photo_alternate,
              size: 50,
              color: Colors.grey,
            ),
          ),
        ),
        Positioned(
          bottom: -50,
          left: MediaQuery.of(context).size.width / 2 - 80,
          child: GestureDetector(
            onTap: () {
              // Add logic to pick profile image
            },
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey[300],
              child: const Icon(
                Icons.add_a_photo,
                size: 30,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      ],
    );
  }
}