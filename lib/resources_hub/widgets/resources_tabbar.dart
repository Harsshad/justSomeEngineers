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
    return selectedIndex == 0
        ? TabBar(
            controller: tabController,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
            labelColor: Colors.white,
            unselectedLabelColor: Theme.of(context).colorScheme.primary,
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