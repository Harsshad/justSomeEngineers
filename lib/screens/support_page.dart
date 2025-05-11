import 'package:codefusion/global_resources/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportPage extends StatelessWidget {
  final String supportUrl = 'https://buymeacoffee.com/harsshad';

  void _launchSupportLink() async {
    final Uri url = Uri.parse(supportUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $supportUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Support Page",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Lottie.asset(
                Constants.profile_gif,
                height: 250,
                width: 250,
                fit: BoxFit.cover,
              ),
              // const Icon(Icons.favorite, color: Colors.pinkAccent, size: 50),
              const SizedBox(height: 20),
              Text(
                'Support CodeFusion',
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              Text(
                "Hey there! I'm a student developer working hard to keep this platform running. "
                "Your small contribution – starting from ₹50 or \$5 – will help cover essential costs like APIs, servers, and future features.",
                style: TextStyle(fontSize: 16, color: isDark ? Colors.white : Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _launchSupportLink,
                icon: const Icon(Icons.local_cafe),
                label: const Text("Buy Me a Coffee"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown[400],
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'Prefer UPI? Scan below with Google Pay, PhonePe, or any UPI app:',
                style: TextStyle(fontSize: 15, color: isDark ? Colors.white : Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  Constants.support,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Thank you for supporting and keeping this dream alive! 🚀',
                style: TextStyle(fontSize: 14, color: isDark ? Colors.white : Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40), // spacing at bottom
            ],
          ),
        ),
      ),
    );
  }
}
