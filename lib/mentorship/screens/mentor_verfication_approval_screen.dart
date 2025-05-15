import 'package:codefusion/global_resources/constants/constants.dart';
import 'package:codefusion/global_resources/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MentorPendingApprovalScreen extends StatelessWidget {
  final String googleFormUrl =
      'https://docs.google.com/forms/d/e/1FAIpQLScHSB37ucnznDhPnYESXMS0Yx7BhYcchXkoPX5x-_q1KDts-w/viewform?usp=preview'; // <-- Replace with your link

  const MentorPendingApprovalScreen({super.key});

  Widget _buildBackground(bool isDarkMode) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [Colors.black87, Colors.blueGrey.shade900]
                : [const Color(0xFFDFD7C2), const Color(0xFFF7DB4C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          image: const DecorationImage(
            image: AssetImage(Constants.default_banner),
            fit: BoxFit.cover,
            opacity: 0.3,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Verification Pending',
        showBackButton: false,
      ),
      body: Stack(
        children: [
          _buildBackground(isDark),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.hourglass_top_rounded,
                      size: 100, color: Colors.orange),
                  const SizedBox(height: 30),
                  const Text(
                    'Thanks for submitting your details.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'We’re reviewing your credentials. You’ll be notified once verified.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 30),
                  const Divider(height: 1),
                  const SizedBox(height: 20),
                  const Text(
                    'We need your documents to verify your credentials, so please upload them using the link below.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () async {
                      if (await canLaunchUrl(Uri.parse(googleFormUrl))) {
                        await launchUrl(Uri.parse(googleFormUrl));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Could not open form')),
                        );
                      }
                    },
                    icon: const Icon(Icons.upload_file_rounded),
                    label: const Text('Upload via Google Form'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      padding: const EdgeInsets.symmetric(
                          vertical: 14.0, horizontal: 24.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Alternatively, you can use CodeFusion as a user while waiting.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/onboard-screen');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark
                            ? Colors.tealAccent[700]
                            : Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            vertical: 14.0, horizontal: 24.0),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Get Started as User',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
