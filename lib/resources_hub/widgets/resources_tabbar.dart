import 'package:flutter/material.dart';

class ResourcesTabBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController tabController;
  final int selectedIndex;

  const ResourcesTabBar({
    Key? key,
    required this.tabController,
    required this.selectedIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return selectedIndex == 0
        ? TabBar(
            controller: tabController,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: const Color(0xFF615D52).withOpacity(0.8),
            ),
            labelColor: Colors.white,
            unselectedLabelColor: (isDarkMode ? Colors.white :  Colors.black),
            tabs: const [
              Tab(
                text: '   Medium Articles   ',
              ),
              Tab(
                text: '   Dev.to Articles   ',
              ),
            ],
          )
        : Container();
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}