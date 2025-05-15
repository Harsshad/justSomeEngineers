import 'package:codefusion/global_resources/constants/constants.dart';
import 'package:codefusion/intro_page/widgets/build_page.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  bool isLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() => isLastPage = index == 4);
            },
            children: [
              buildPage(
                title: "Welcome to CodeFusion",
                desc:
                    "Your dev journey starts here. Learn, connect, and grow with the community.",
                image: Constants.welcome,
                gradient: const LinearGradient(
                    colors: [Colors.deepPurple, Colors.purpleAccent]),
              ),
              buildPage(
                title: "Ask & Learn",
                desc:
                    "Use CodeMate AI or community Q&A to solve doubts and share knowledge.",
                image: Constants.chat_bot,
                gradient: const LinearGradient(
                    colors: [Colors.indigo, Colors.blueAccent]),
              ),
              buildPage(
                title: "Mentorship Made Easy",
                desc:
                    "Find mentors by domain, send requests, and grow with their guidance.",
                image: Constants.mentor,
                gradient: const LinearGradient(
                    colors: [Colors.teal, Colors.cyanAccent]),
              ),
              buildPage(
                title: "Resources & Roadmaps",
                desc:
                    "Explore articles, videos, and roadmaps to master any tech stack.",
                image: Constants.resources,
                gradient: const LinearGradient(
                    colors: [Colors.orange, Colors.deepOrangeAccent]),
              ),
              buildPage(
                title: "Chat, Meet & Get Hired",
                desc:
                    "Chat, video meet, build resumes, and find jobs from LinkedIn.",
                image: Constants.job,
                gradient: const LinearGradient(
                    colors: [Colors.green, Colors.lightGreenAccent]),
              ),
            ],
          ),
           Positioned(
            top: 50,
            right: 20,
            child: Visibility(
              visible: !isLastPage,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/main-home');
                },
                child: const Text(
                  "Skip",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        blurRadius: 4,
                        offset: Offset(1, 2),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),

          Container(
            alignment: const Alignment(0, 0.75),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SmoothPageIndicator(
                  controller: _controller,
                  count: 5,
                  effect: WormEffect(
                    spacing: 12,
                    dotColor: Colors.grey.shade400,
                    activeDotColor: Colors.white,
                    dotHeight: 10,
                    dotWidth: 10,
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: ElevatedButton(
                    onPressed: () {
                      if (isLastPage) {
                        Navigator.of(context)
                            .pushReplacementNamed('/main-home');
                      } else {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 60, vertical: 15),
                    ),
                    child: Text(isLastPage ? "Get Started" : "Next"),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          )
        ],
      ),
    );
  }
}
