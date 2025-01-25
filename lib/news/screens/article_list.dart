import 'package:codefusion/news/services/article_functions.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';


class ArticleList extends StatefulWidget {
  const ArticleList({Key? key}) : super(key: key);

  @override
  ArticleListState createState() => ArticleListState();
}

class ArticleListState extends State<ArticleList> {
  static List<dynamic> _articles = [];

  @override
  void initState() {
    super.initState();
    _fetchArticles(" ");
  }

  static void refreshArticles(BuildContext context) {
    final state = context.findAncestorStateOfType<ArticleListState>();
    state?._fetchArticles(" ");
  }

  void _fetchArticles(String tag) async {
    try {
      setState(() {
        _articles = []; // Clear existing articles
      });
      final articles = await fetchArticles(tag);
      setState(() {
        _articles = articles;
      });
    } catch (e) {
      print('Error fetching articles: $e');
    }
  }

  void _showArticleDetails(BuildContext context, Map<String, dynamic> article) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                article['title'],
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                article['description'] ?? "No description available",
                style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(height: 12),
              Text(
                'Published on: ${article['published_at']}',
                style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.link),
                label: const Text("Read Full Article"),
                onPressed: () {
                  if (article['url'] != null) {
                    _launchURL(article['url']);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return _articles.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: _articles.length,
            itemBuilder: (context, index) {
              final article = _articles[index];
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (article['cover_image'] != null)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: Image.network(
                          article['cover_image'],
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            article['title'],
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            article['description'] ?? "No description available",
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '❤️ ${article['positive_reactions_count']} Likes',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                                onPressed: () => _showArticleDetails(context, article),
                                child: Text(
                                  'Read More',
                                  style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
  }
}
