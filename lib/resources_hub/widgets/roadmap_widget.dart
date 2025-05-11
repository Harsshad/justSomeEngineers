import 'package:flutter/material.dart';

class RoadmapWidget extends StatelessWidget {
  final String roadmap;

  const RoadmapWidget({super.key, required this.roadmap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (roadmap.isEmpty) {
      return Container();
    }
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(
          top: 12.0,
          bottom: 18,
          right: 12,
          left: 12,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          margin: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 12),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            // color: const Color(0xFF615D52).withOpacity(0.8),
            color: isDark ? Colors.white : Colors.black,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withOpacity(0.5),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16.0),
          child: _parseRoadmapContent(context, roadmap),
        ),
      ),
    );
  }

  Widget _parseRoadmapContent(BuildContext context, String content) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final regex = RegExp(r'\*\*(.*?)\*\*');
    final matches = regex.allMatches(content);

    if (matches.isEmpty) {
      return Text(
        content,
        style: TextStyle(
          fontSize: 16,
          color: (isDarkMode ? Colors.black : Colors.white),
        ),
      );
    }

    List<TextSpan> spans = [];
    int lastMatchEnd = 0;

    for (final match in matches) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: content.substring(lastMatchEnd, match.start),
          style: TextStyle(
            fontSize: 16,
            color: (isDarkMode ? Colors.black : Colors.white),
          ),
        ));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: (isDarkMode ? Colors.black : Colors.white),
        ),
      ));
      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < content.length) {
      spans.add(TextSpan(
        text: content.substring(lastMatchEnd),
        style: TextStyle(
          fontSize: 16,
          color: (isDarkMode ? Colors.black : Colors.white),
        ),
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}
