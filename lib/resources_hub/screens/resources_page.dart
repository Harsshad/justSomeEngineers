import 'package:codefusion/resources_hub/services/devto_service.dart';
import 'package:codefusion/resources_hub/services/medium_service.dart';
import 'package:flutter/material.dart';
import 'package:codefusion/resources_hub/services/resources_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class ResourcesPage extends StatefulWidget {
  const ResourcesPage({Key? key}) : super(key: key);

  @override
  _ResourcesPageState createState() => _ResourcesPageState();
}

class _ResourcesPageState extends State<ResourcesPage> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ResourcesService _resourcesService = ResourcesService();
  List<Article> _articles = [];
  List<Video> _videos = [];
  List<DevToArticle> _devToArticles = [];
  bool _isLoading = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  void _searchResources() async {
    setState(() {
      _isLoading = true;
      _articles = [];
      _videos = [];
      _devToArticles = [];
    });

    try {
      final results = await _resourcesService.searchResources(_searchController.text);
      setState(() {
        _articles = results['articles'];
        _videos = results['videos'];
        _devToArticles = results['devToArticles'];
      });
    } catch (e) {
      print('Error fetching resources: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching resources: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resources 📚'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Medium Articles 📰'),
            Tab(text: 'YouTube Videos 🎥'),
            Tab(text: 'Dev.to Articles 📝'),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for resources... 🔍',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchResources,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildArticlesList(_articles, theme),
                        _buildVideosList(theme),
                        _buildDevToArticlesList(_devToArticles, theme),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticlesList(List<Article> articles, ThemeData theme) {
    return ListView.builder(
      itemCount: articles.length,
      itemBuilder: (context, index) {
        final article = articles[index];
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Card(
            color: theme.colorScheme.secondary,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(Icons.article, color: Colors.blue),
              title: Text(
                article.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: theme.colorScheme.inversePrimary,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  article.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: theme.colorScheme.inversePrimary),
                ),
              ),
              onTap: () {
                // Open article in browser
                launch(article.link);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildVideosList(ThemeData theme) {
    return ListView.builder(
      itemCount: _videos.length,
      itemBuilder: (context, index) {
        final video = _videos[index];
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: GestureDetector(
            onTap: () {
              // Open video in YouTube app or browser
              launch('https://www.youtube.com/watch?v=${video.id}');
            },
            child: Card(
              color: theme.colorScheme.secondary,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CachedNetworkImage(
                    imageUrl: video.thumbnails.highResUrl,
                    placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          video.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: theme.colorScheme.inversePrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Duration: ${video.duration?.inMinutes ?? 0} min',
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.inversePrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDevToArticlesList(List<DevToArticle> devToArticles, ThemeData theme) {
    return ListView.builder(
      itemCount: devToArticles.length,
      itemBuilder: (context, index) {
        final article = devToArticles[index];
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Card(
            color: theme.colorScheme.secondary,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(Icons.article, color: Colors.green),
              title: Text(
                article.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: theme.colorScheme.inversePrimary,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  article.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: theme.colorScheme.inversePrimary),
                ),
              ),
              onTap: () {
                // Open article in browser
                launch(article.url);
              },
            ),
          ),
        );
      },
    );
  }
}