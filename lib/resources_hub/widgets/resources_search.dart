import 'package:flutter/material.dart';
import 'package:codefusion/resources_hub/services/resources_service.dart';
import 'package:codefusion/resources_hub/services/gemini_service.dart';

class ResourcesSearch extends StatefulWidget {
  final Function(List<dynamic>, List<dynamic>, List<dynamic>, String) onSearchComplete;
  final TextEditingController searchController;
  final TextEditingController videoSearchController;
  final ResourcesService resourcesService;
  final GeminiService geminiService;
  final bool isRoadmapSearch;

  const ResourcesSearch({
    Key? key,
    required this.onSearchComplete,
    required this.searchController,
    required this.videoSearchController,
    required this.resourcesService,
    required this.geminiService,
    this.isRoadmapSearch = false,
  }) : super(key: key);

  @override
  _ResourcesSearchState createState() => _ResourcesSearchState();
}

class _ResourcesSearchState extends State<ResourcesSearch> {
  bool _isLoading = false;

  void _searchResources() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final query = widget.searchController.text.trim().toLowerCase();
      final results = await widget.resourcesService.searchResources(query);
      widget.onSearchComplete(results['articles'], results['videos'], results['devToArticles'], '');
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
    });

    try {
      final query = widget.videoSearchController.text.trim().toLowerCase();
      final results = await widget.resourcesService.searchVideos(query);
      widget.onSearchComplete([], results, [], '');
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
    });

    try {
      final query = widget.searchController.text.trim().toLowerCase();
      final roadmap = await widget.geminiService.getRoadmap(query);
      widget.onSearchComplete([], [], [], roadmap);
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: widget.searchController,
          textInputAction: TextInputAction.search,
          onSubmitted: (value) {
            if (widget.isRoadmapSearch) {
              _searchRoadmap();
            } else if (widget.searchController == widget.videoSearchController) {
              _searchVideos();
            } else {
              _searchResources();
            }
          },
          decoration: InputDecoration(
            hintText: widget.isRoadmapSearch ? 'Search for roadmap...' : 'Search for resources...',
            suffixIcon: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                if (widget.isRoadmapSearch) {
                  _searchRoadmap();
                } else if (widget.searchController == widget.videoSearchController) {
                  _searchVideos();
                } else {
                  _searchResources();
                }
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Container(),
      ],
    );
  }
}