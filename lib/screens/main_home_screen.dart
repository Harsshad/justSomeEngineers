
import 'package:codefusion/global_resources/widgets/drawer_widget.dart';
import 'package:codefusion/global_resources/widgets/responsive_layout.dart';
import 'package:codefusion/news/screens/article_list.dart';
import 'package:flutter/material.dart';

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({Key? key}) : super(key: key);

  @override
  _MainHomeScreenState createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  final GlobalKey<ArticleListState> _articleListKey = GlobalKey<ArticleListState>();

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileLayout: Scaffold(
        appBar: AppBar(
          leading: Builder(
            builder: (context) => IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: Icon(
                Icons.menu,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
          ),
          centerTitle: true,
          title: const Text(
            'CodeFusion',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                _articleListKey.currentState?.refreshArticles();
              },
            ),
          ],
        ),
        drawer: const DrawerWidget(),
        body: ArticleList(key: _articleListKey),
      ),
      tabletLayout: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'CodeFusion',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                _articleListKey.currentState?.refreshArticles();
              },
            ),
          ],
        ),
        drawer: const DrawerWidget(),
        body: Row(
          children: [
            const SizedBox(
              width: 250, // Fixed width for the drawer
              child: DrawerWidget(),
            ),
            Expanded(
              child: ArticleList(key: _articleListKey),
            ),
          ],
        ),
      ),
      webLayout: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'CodeFusion',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                _articleListKey.currentState?.refreshArticles();
              },
            ),
          ],
        ),
        body: Row(
          children: [
            const SizedBox(
              width: 300, // Wider drawer for web
              child: DrawerWidget(),
            ),
            Expanded(
              child: ArticleList(key: _articleListKey),
            ),
          ],
        ),
      ),
    );
  }
}