import 'package:codefusion/resources_hub/services/devto_service.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DevToArticleList extends StatelessWidget {
  final List<DevToArticle> devToArticles;

  const DevToArticleList({Key? key, required this.devToArticles})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView.builder(
      itemCount: devToArticles.length,
      itemBuilder: (context, index) {
        final article = devToArticles[index];
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(
            vertical: 8.0,
            horizontal: 18,
          ),
          decoration: BoxDecoration(
            color: isDark ? Colors.white : Colors.black,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: ListTile(
            title: Text(
              article.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                article.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
            ),
            onTap: () {
              // Open article in browser
              launch(article.url);
            },
          ),
        );
      },
    );
  }
}
