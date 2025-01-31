import 'package:codefusion/resources_hub/models/article_list.dart';
import 'package:codefusion/resources_hub/models/devto_article_list.dart';
import 'package:codefusion/resources_hub/models/video_list.dart';
import 'package:codefusion/resources_hub/services/devto_service.dart';
import 'package:codefusion/resources_hub/services/gemini_service.dart';
import 'package:codefusion/resources_hub/services/medium_service.dart';
import 'package:codefusion/resources_hub/services/resources_service.dart';
import 'package:codefusion/resources_hub/widgets/roadmap_widget.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class ResourcesPage extends StatefulWidget {
  const ResourcesPage({Key? key}) : super(key: key);

  @override
  _ResourcesPageState createState() => _ResourcesPageState();
}

class _ResourcesPageState extends State<ResourcesPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _videoSearchController = TextEditingController();
  final ResourcesService _resourcesService = ResourcesService();
  final GeminiService _geminiService =
      GeminiService('AIzaSyDzNOkzb-qUdtXEAWXIYKRtVWi438Lwh54');
  List<Article> _articles = [];
  List<Video> _videos = [];
  List<DevToArticle> _devToArticles = [];
  String _roadmap = '';
  bool _isLoading = false;
  int _selectedIndex = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _searchResources() async {
    setState(() {
      _isLoading = true;
      _articles = [];
      _videos = [];
      _devToArticles = [];
      _roadmap = '';
    });

    try {
      final query = _searchController.text.toLowerCase();
      final results = await _resourcesService.searchResources(query);
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

  void _searchVideos() async {
    setState(() {
      _isLoading = true;
      _videos = [];
    });

    try {
      final query = _videoSearchController.text.toLowerCase();
      final results = await _resourcesService.searchVideos(query);
      setState(() {
        _videos = results;
      });
    } catch (e) {
      print('Error fetching videos: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching videos: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _searchRoadmap() async {
    setState(() {
      _isLoading = true;
      _roadmap = '';
    });

    try {
      final query = _searchController.text.toLowerCase();
      final roadmap = await _geminiService.getRoadmap(query);
      setState(() {
        _roadmap = roadmap;
      });
    } catch (e) {
      print('Error fetching roadmap: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching roadmap: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text(
          'Resources Hub',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: _selectedIndex == 0
            ? TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(
                    text: 'Medium Articles ',
                  ),
                  Tab(
                    text: 'Dev.to Articles ',
                  ),
                ],
              )
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_selectedIndex == 0) ...[
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search for resources... ',
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
                          ArticleList(articles: _articles),
                          DevToArticleList(devToArticles: _devToArticles),
                        ],
                      ),
                    ),
            ] else if (_selectedIndex == 1) ...[
              TextField(
                controller: _videoSearchController,
                decoration: InputDecoration(
                  hintText: 'Search for videos... ',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _searchVideos,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Expanded(child: VideoList(videos: _videos)),
            ] else if (_selectedIndex == 2) ...[
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search for roadmap... ',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _searchRoadmap,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Expanded(child: RoadmapWidget(roadmap: _roadmap)),
              const SizedBox(height: 56),
            ],
          ],
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        color: Theme.of(context).colorScheme.background,
        buttonBackgroundColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        items: <Widget>[
          Icon(
            Icons.article_outlined,
            size: 30,
            color: Theme.of(context).colorScheme.primary,
          ),
          Icon(
            Icons.video_library_outlined,
            size: 30,
            color: Theme.of(context).colorScheme.primary,
          ),
          Icon(
            Icons.map_outlined,
            size: 30,
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
        onTap: _onTabSelected,
        index: _selectedIndex,
      ),
    );
  }
}
