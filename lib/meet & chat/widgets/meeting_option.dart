import 'package:flutter/material.dart';

import '../utils/colors.dart';

class MeetingOption extends StatelessWidget {
  final String text;
  final bool isMute;
  final Function(bool) onChange;
  const MeetingOption({
    Key? key,
    required this.text,
    required this.isMute,
    required this.onChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 60,
      decoration: BoxDecoration(
        // border: Border.all(color: Colors.grey),
        gradient: LinearGradient(
          colors: isDarkMode
              ? [Colors.black87, Colors.blueGrey.shade900] // Dark mode gradient
              : [const Color(0xFFDFD7C2), const Color(0xFFF7DB4C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.only(left: 15, right: 15),
      padding: EdgeInsets.only(left: 15, right: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: (isDarkMode ? Colors.white : Colors.black),
              ),
            ),
          ),
          Switch.adaptive(value: isMute, onChanged: onChange, activeColor: Colors.white,)
        ],
      ),
    );
  }
}
