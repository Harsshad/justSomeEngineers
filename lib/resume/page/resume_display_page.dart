import 'package:flutter/material.dart';

class ResumeDisplayPage extends StatelessWidget {
  final String fullName;
  final String currentPosition;
  final String bio;
  final String address;
  final List<String> experiences;
  final List<String> educationDetails;
  final List<String> languages;
  final List<String> hobbies;
  final String email;
  final String profileImage;

  const ResumeDisplayPage({
    Key? key,
    required this.fullName,
    required this.currentPosition,
    required this.bio,
    required this.address,
    required this.experiences,
    required this.educationDetails,
    required this.languages,
    required this.hobbies,
    required this.email,
    required this.profileImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Your Resume'),
        backgroundColor: Colors.blueGrey[900],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Section
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: profileImage.isNotEmpty
                            ? NetworkImage(profileImage)
                            : const AssetImage('assets/images/default_profile.png')
                                as ImageProvider,
                        backgroundColor: Colors.grey[300],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        fullName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        currentPosition,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.blueGrey,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        email,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.blueGrey,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        address,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
          
                // Bio Section
                const Text(
                  'Bio',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  bio,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 20),
          
                // Experience Section
                const Text(
                  'Experience',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                ...experiences.map((experience) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: Row(
                        children: [
                          const Icon(Icons.work, color: Colors.blueGrey, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              experience,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 20),
          
                // Education Section
                const Text(
                  'Education',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                ...educationDetails.map((education) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: Row(
                        children: [
                          const Icon(Icons.school, color: Colors.blueGrey, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              education,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 20),
          
                // Languages Section
                const Text(
                  'Languages',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  children: languages
                      .map((language) => Chip(
                            label: Text(language),
                            backgroundColor: Colors.blueGrey[100],
                          ))
                      .toList(),
                ),
                const SizedBox(height: 20),
          
                // Hobbies Section
                const Text(
                  'Hobbies',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  children: hobbies
                      .map((hobby) => Chip(
                            label: Text(hobby),
                            backgroundColor: Colors.blueGrey[100],
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Add functionality to download the resume
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Download functionality coming soon!'),
            ),
          );
        },
        label: const Text('Download Resume'),
        icon: const Icon(Icons.download),
        backgroundColor: Colors.blueGrey[900],
      ),
    );
  }
}