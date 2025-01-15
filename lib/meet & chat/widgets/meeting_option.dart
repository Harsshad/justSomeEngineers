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
    return Container(
      height: 60,
      decoration: BoxDecoration(
        // border: Border.all(color: Colors.grey),
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.only(left: 15,right: 15),
        padding:EdgeInsets.only(left: 15,right: 15),
        
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Switch.adaptive(value: isMute, onChanged: onChange)
        ],
      ),
    );
  }
}
