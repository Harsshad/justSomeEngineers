import 'package:flutter/material.dart';
import 'package:codefusion/resources_hub/services/medium_service.dart';
import 'package:codefusion/resources_hub/services/youtube_explode_service.dart';
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
  final MediumService _mediumService = MediumService();
  final YoutubeExplodeService _youtubeService = YoutubeExplodeService();
  List<Article> _articles = [];
  List<Video> _videos = [];
  bool _isLoading = false;
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
    });

    try {
      final articles = await _mediumService.searchArticles(_searchController.text);
      final videos = await _youtubeService.searchVideos(_searchController.text);

      setState(() {
        _articles = articles;
        _videos = videos;
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
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: const Text('Resources'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Medium Articles'),
            Tab(text: 'YouTube Videos'),
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
                hintText: 'Search for resources...',
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
                        _buildArticlesList(),
                        _buildVideosList(),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticlesList() {
    return ListView.builder(
      itemCount: _articles.length,
      itemBuilder: (context, index) {
        final article = _articles[index];
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text(
                article.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  article.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
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

  Widget _buildVideosList() {
    return ListView.builder(
      itemCount: _videos.length,
      itemBuilder: (context, index) {
        final video = _videos[index];
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: CachedNetworkImage(
                imageUrl: video.thumbnails.highResUrl,
                placeholder: (context, url) => const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
              title: Text(
                video.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  video.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              onTap: () {
                // Open video in YouTube app or browser
                launch('https://www.youtube.com/watch?v=${video.id}');
              },
            ),
          ),
        );
      },
    );
  }
}





// import 'package:flutter/material.dart';
// import 'package:codefusion/resources_hub/services/medium_service.dart';
// import 'package:codefusion/resources_hub/services/youtube_rss_service.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:youtube_player_iframe/youtube_player_iframe.dart';

// class ResourcesPage extends StatefulWidget {
//   const ResourcesPage({Key? key}) : super(key: key);

//   @override
//   _ResourcesPageState createState() => _ResourcesPageState();
// }

// class _ResourcesPageState extends State<ResourcesPage> with SingleTickerProviderStateMixin {
//   final TextEditingController _searchController = TextEditingController();
//   final MediumService _mediumService = MediumService();
//   final YouTubeRssService _youtubeService = YouTubeRssService();
//   List<Article> _articles = [];
//   List<Video> _videos = [];
//   bool _isLoading = false;
//   late TabController _tabController;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//   }

//   void _searchResources() async {
//     setState(() {
//       _isLoading = true;
//       _articles = [];
//       _videos = [];
//     });

//     try {
//       final articles = await _mediumService.searchArticles(_searchController.text);
//       final videos = await _youtubeService.searchVideos(_searchController.text);

//       setState(() {
//         _articles = articles;
//         _videos = videos;
//       });
//     } catch (e) {
//       print('Error fetching resources: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching resources: $e')),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Resources'),
//         bottom: TabBar(
//           controller: _tabController,
//           tabs: const [
//             Tab(text: 'Medium Articles'),
//             Tab(text: 'YouTube Videos'),
//           ],
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _searchController,
//               decoration: InputDecoration(
//                 hintText: 'Search for resources...',
//                 suffixIcon: IconButton(
//                   icon: const Icon(Icons.search),
//                   onPressed: _searchResources,
//                 ),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12.0),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             _isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : Expanded(
//                     child: TabBarView(
//                       controller: _tabController,
//                       children: [
//                         _buildArticlesList(),
//                         _buildVideosList(),
//                       ],
//                     ),
//                   ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildArticlesList() {
//     return ListView.builder(
//       itemCount: _articles.length,
//       itemBuilder: (context, index) {
//         final article = _articles[index];
//         return AnimatedContainer(
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeInOut,
//           margin: const EdgeInsets.symmetric(vertical: 8.0),
//           child: Card(
//             elevation: 4,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: ListTile(
//               title: Text(
//                 article.title,
//                 style: const TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 18,
//                 ),
//               ),
//               subtitle: Padding(
//                 padding: const EdgeInsets.only(top: 8.0),
//                 child: Text(
//                   article.description,
//                   maxLines: 3,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//               onTap: () {
//                 // Open article in browser
//                 launch(article.link);
//               },
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildVideosList() {
//     return ListView.builder(
//       itemCount: _videos.length,
//       itemBuilder: (context, index) {
//         final video = _videos[index];
//         return AnimatedContainer(
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeInOut,
//           margin: const EdgeInsets.symmetric(vertical: 8.0),
//           child: Card(
//             elevation: 4,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Column(
//               children: [
//                 YoutubePlayerIFrame(
//                   controller: YoutubePlayerController(
//                     initialVideoId: video.videoId,
//                     params: const YoutubePlayerParams(
//                       showControls: true,
//                       showFullscreenButton: true,
//                     ),
//                   ),
//                   aspectRatio: 16 / 9,
//                 ),
//                 ListTile(
//                   title: Text(
//                     video.title,
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 18,
//                     ),
//                   ),
//                   onTap: () {
//                     // Open video in YouTube app or browser
//                     launch(video.link);
//                   },
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }