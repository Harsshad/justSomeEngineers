import 'package:codefusion/config.dart';
import 'package:codefusion/resources_hub/services/devto_service.dart';
import 'package:codefusion/resources_hub/services/medium_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:codefusion/resources_hub/models/article_list.dart';
import 'package:codefusion/resources_hub/models/devto_article_list.dart';
import 'package:codefusion/resources_hub/models/video_list.dart';
import 'package:codefusion/resources_hub/services/gemini_service.dart';
import 'package:codefusion/resources_hub/services/resources_service.dart';
import 'package:codefusion/resources_hub/widgets/roadmap_widget.dart';
import 'package:codefusion/resources_hub/widgets/resources_search.dart';
import 'package:codefusion/resources_hub/widgets/resources_tabbar.dart';
import 'package:codefusion/resources_hub/widgets/resources_tabview.dart';
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
      GeminiService(Config.geminiApi);
  List<Article> _articles = [];
  List<Video> _videos = [];
  List<DevToArticle> _devToArticles = [];
  String _roadmap = '';
  bool _isLoading = false;
  int _selectedIndex = 0;
  late TabController _tabController;
  List<Map<String, dynamic>> _savedRoadmaps = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSavedRoadmaps();
  }

  Future<void> _loadSavedRoadmaps() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      QuerySnapshot roadmapDocs = await FirebaseFirestore.instance
          .collection('roadmaps')
          .where('uid', isEqualTo: user.uid)
          .get();
      setState(() {
        _savedRoadmaps = roadmapDocs.docs.map((doc) => {
              'id': doc.id,
              'roadmap': doc['roadmap'],
            }).toList();
      });
    }
  }

  Future<void> _saveRoadmap(String roadmap) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('roadmaps').add({
        'uid': user.uid,
        'roadmap': roadmap,
      });
      _loadSavedRoadmaps();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Roadmap saved successfully!')),
      );
    }
  }

  void _onSearchComplete(List<dynamic> articles, List<dynamic> videos,
      List<dynamic> devToArticles, String roadmap) {
    setState(() {
      _articles = articles.cast<Article>();
      _videos = videos.cast<Video>();
      _devToArticles = devToArticles.cast<DevToArticle>();
      _roadmap = roadmap;
    });
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _viewSavedRoadmaps() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView.builder(
          itemCount: _savedRoadmaps.length,
          itemBuilder: (context, index) {
            String roadmapTitle = _savedRoadmaps[index]['roadmap'];

            // Check if the roadmap title starts and ends with '!!!'
            bool isHeading = roadmapTitle.startsWith('!!!') && roadmapTitle.endsWith('!!!');

            return Column(
              children: [
                ListTile(
                  title: Text(
                    isHeading ? roadmapTitle.substring(3, roadmapTitle.length - 3) : roadmapTitle,
                    style: TextStyle(
                      fontWeight: isHeading ? FontWeight.bold : FontWeight.normal,
                      color: isHeading ? Colors.blue : Colors.black,
                      shadows: isHeading
                          ? [Shadow(blurRadius: 10.0, color: Colors.blueAccent, offset: Offset(2.0, 2.0))]
                          : null,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context); // Close bottom sheet
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RoadmapDetailPage(
                            roadmapId: _savedRoadmaps[index]['id']),
                      ),
                    );
                  },
                ),
                if (isHeading)
                  Divider(
                    color: Colors.blue,
                    thickness: 2.0,
                  ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      // appBar: AppBar(
      //   title: Text(
      //     'Resume Generator',
      //     style: TextStyle(
      //       fontFamily: 'SourceCodePro',
      //       fontWeight: FontWeight.bold,
      //       color: Theme.of(context).colorScheme.primary,
      //     ),
      //   ),
      //   backgroundColor: Colors.blueGrey[800],
      // ),
      appBar: AppBar(
         leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/main-home',
              (route) => false,
            );

            // Go back to the previous page
          },
        ),
        title:  Text(
          'Resources Hub',
          style: TextStyle(
            fontFamily: 'SourceCodePro',
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        backgroundColor: Colors.blueGrey[800],
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: _viewSavedRoadmaps,
          ),
        ],
        bottom: _selectedIndex == 0
            ? ResourcesTabBar(
                tabController: _tabController,
                selectedIndex: _selectedIndex,
              )
            : null,
      ),
      body: Column(
        children: [
          if (_selectedIndex == 0 || _selectedIndex == 1) ...[
            ResourcesSearch(
              onSearchComplete: _onSearchComplete,
              searchController: _selectedIndex == 0
                  ? _searchController
                  : _videoSearchController,
              videoSearchController: _videoSearchController,
              resourcesService: _resourcesService,
              geminiService: _geminiService,
            ),
            const SizedBox(height: 16),
          ] else if (_selectedIndex == 2) ...[
            ResourcesSearch(
              onSearchComplete: _onSearchComplete,
              searchController: _searchController,
              videoSearchController: _videoSearchController,
              resourcesService: _resourcesService,
              geminiService: _geminiService,
              isRoadmapSearch: true,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: RoadmapWidget(roadmap: _roadmap),
            ),
            const SizedBox(height: 16),
          ],
          if (_selectedIndex != 2)
            Expanded(
              child: ResourcesTabView(
                tabController: _tabController,
                isLoading: _isLoading,
                articles: _articles,
                devToArticles: _devToArticles,
                videos: _videos,
                selectedIndex: _selectedIndex,
              ),
            ),
        ],
      ),
      floatingActionButton: _selectedIndex == 2
          ? FloatingActionButton(
              onPressed: () => _saveRoadmap(_roadmap),
              child: const Icon(Icons.save),
            )
          : null,
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

class RoadmapDetailPage extends StatelessWidget {
  final String roadmapId;

  const RoadmapDetailPage({Key? key, required this.roadmapId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Roadmap Detail')),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('roadmaps').doc(roadmapId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Roadmap not found'));
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: RoadmapWidget(roadmap: snapshot.data!['roadmap']),
          );
        },
      ),
    );
  }
}