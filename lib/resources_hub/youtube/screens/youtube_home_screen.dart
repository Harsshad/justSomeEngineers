import 'package:codefusion/resources_hub/youtube/models/video_model.dart';
import 'package:codefusion/resources_hub/youtube/screens/video_screen.dart';
import 'package:codefusion/resources_hub/youtube/services/api_service.dart';
import 'package:flutter/material.dart';

class YoutubeHomeScreen extends StatefulWidget {
  @override
  _YoutubeHomeScreenState createState() => _YoutubeHomeScreenState();
}

class _YoutubeHomeScreenState extends State<YoutubeHomeScreen> {
  List<Video> _videos = [];
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();

  void _search(String query) async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Video> searchedVideos =
          await APIService.instance.searchVideos(query);
      setState(() {
        _videos = searchedVideos;
      });
    } catch (e) {
      print("Error: $e");
    }

    setState(() {
      _isLoading = false;
    });
  }

  Widget _buildSearchBar() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(16),
        child: TextField(
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          controller: _searchController,
          textInputAction: TextInputAction.search,
          onSubmitted: _search,
          decoration: InputDecoration(
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            hintText: 'Search for videos...',
            hintStyle: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            filled: true,
            fillColor: Colors.transparent,
            suffixIcon: IconButton(
              icon: Icon(
                Icons.search,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              onPressed: () => _search(_searchController.text),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoTile(Video video) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => VideoScreen(id: video.id)),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            const BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.network(
                video.thumbnailUrl,
                width: 140.0,
                height: 90,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    video.channelTitle ?? '',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            _isLoading
                ? const Expanded(
                    child: Center(child: CircularProgressIndicator()))
                : Expanded(
                    child: _videos.isEmpty
                        ? Center(
                            child: Text(
                              "Search for a topic to view videos.",
                              style: TextStyle(
                                fontSize: 16,
                                color: isDarkMode
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _videos.length,
                            itemBuilder: (context, index) {
                              return _buildVideoTile(_videos[index]);
                            },
                          ),
                  ),
          ],
        ),
      ),
    );
  }
}
