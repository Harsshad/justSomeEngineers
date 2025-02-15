import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  final String text;
  final void Function()? onTap;

  const UserTile({
    super.key,
    required this.text,
    required this.onTap,
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
          padding: EdgeInsets.all(18),
          child: Row(children: [
            //icon
            Icon(Icons.person),

            const SizedBox(width: 20,),

            //username
            Text(text),
          ])),
    );
  }
}
