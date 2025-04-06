import 'dart:ui';
import 'package:codefusion/config.dart';
import 'package:codefusion/resources_hub/screens/roadmap_detail_page.dart';
import 'package:codefusion/resources_hub/services/devto_service.dart';
import 'package:codefusion/resources_hub/services/medium_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
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
  final GeminiService _geminiService = GeminiService(Config.geminiApi);
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
        _savedRoadmaps = roadmapDocs.docs
            .map((doc) => {
                  'id': doc.id,
                  'roadmap': doc['roadmap'],
                })
            .toList();
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
        const SnackBar(content: Text('Roadmap saved successfully!')),
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView.builder(
          itemCount: _savedRoadmaps.length,
          itemBuilder: (context, index) {
            String roadmapTitle = _savedRoadmaps[index]['roadmap'];

            // Check if the roadmap title starts and ends with '!!!'
            bool isHeading =
                roadmapTitle.startsWith('!!!') && roadmapTitle.endsWith('!!!');

            return Column(
              children: [
                ListTile(
                  title: Text(
                    isHeading
                        ? roadmapTitle.substring(3, roadmapTitle.length - 3)
                        : roadmapTitle,
                    style: TextStyle(
                      fontWeight:
                          isHeading ? FontWeight.bold : FontWeight.normal,
                       color: (isDarkMode ? Colors.white :  Colors.black),
                      shadows: isHeading
                          ? [
                              const Shadow(
                                blurRadius: 10.0,
                                color: Colors.blueAccent,
                                offset: Offset(2.0, 2.0),
                              )
                            ]
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
                  const Divider(
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
              ? [Colors.black87, Colors.blueGrey.shade900]
              : [const Color(0xFFDFD7C2), const Color(0xFFF7DB4C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/main-home',
                (route) => false,
              );
            },
          ),
          title: Text(
            'Resources Hub',
            style: TextStyle(
              fontFamily: 'SourceCodePro',
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: isDarkMode ? Colors.white : const Color(0xFF2A2824),
            ),
          ),
          flexibleSpace: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDarkMode
                        ? [Colors.black87, Colors.blueGrey.shade900]
                        : [const Color(0xFFDFD7C2), const Color(0xFFF7DB4C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ),
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
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 900,
            ),
            child: Column(
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
          ),
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
              color: (isDarkMode ? Colors.white : Colors.black),
            ),
            Icon(
              Icons.video_library_outlined,
              size: 30,
              color: (isDarkMode ? Colors.white : Colors.black),
            ),
            Icon(
              Icons.map_outlined,
              size: 30,
              color: (isDarkMode ? Colors.white : Colors.black),
            ),
          ],
          onTap: _onTabSelected,
          index: _selectedIndex,
        ),
      ),
    );
  }
}
