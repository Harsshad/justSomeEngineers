import 'package:flutter/material.dart';

class RoadmapWidget extends StatelessWidget {
  final String roadmap;

  const RoadmapWidget({Key? key, required this.roadmap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: const Color(0xFF615D52).withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withOpacity(0.5),
                blurRadius: 10,
                offset: Offset(0, 5),
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
          color: (isDarkMode ? Colors.white : Colors.black),
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
            color: (isDarkMode ? Colors.white : Colors.black),
          ),
        ));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: (isDarkMode ? Colors.white : Colors.black),
        ),
      ));
      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < content.length) {
      spans.add(TextSpan(
        text: content.substring(lastMatchEnd),
        style: TextStyle(
          fontSize: 16,
          color: (isDarkMode ? Colors.white : Colors.black),
        ),
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}
