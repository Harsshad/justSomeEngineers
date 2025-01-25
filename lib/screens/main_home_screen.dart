import 'package:codefusion/global_resources/widgets/drawer_widget.dart';
import 'package:codefusion/news/screens/article_list.dart';
import 'package:flutter/material.dart';


class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({Key? key}) : super(key: key);

  @override
  _MainHomeScreenState createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            onPressed: () => ArticleListState.refreshArticles(context),
          ),
        ],
      ),
      drawer: const DrawerWidget(),
      body: const ArticleList(),
    );
  }
}
