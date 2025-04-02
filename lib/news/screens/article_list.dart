import 'package:codefusion/mentorship/screens/mentor_detail_screen.dart';
import 'package:codefusion/news/services/article_functions.dart';
import 'package:codefusion/news/widgets/article_mentor_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ArticleList extends StatefulWidget {
  const ArticleList({Key? key}) : super(key: key);

  @override
  ArticleListState createState() => ArticleListState();
}

class ArticleListState extends State<ArticleList> {
  List<dynamic> _articles = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchArticles(" ");
  }

  void refreshArticles() {
    _fetchArticles(" ");
  }

  void _fetchArticles(String tag) async {
    setState(() => _isLoading = true);
    try {
      final articles = await fetchArticles(tag);
      setState(() {
        _articles = articles;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching articles: $e');
      setState(() => _isLoading = false);
    }
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not launch the article URL'),
        ),
      );
    }
  }

  /// ✅ Detailed Pop-up (Modal Bottom Sheet)
  void _showArticleDetails(BuildContext context, Map<String, dynamic> article) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Article Image
              if (article['cover_image'] != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    article['cover_image'],
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

              const SizedBox(height: 16),

              // Article Title
              Text(
                article['title'] ?? 'No title available',
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              // Article Description
              Text(
                article['description'] ?? 'No description available',
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),

              const SizedBox(height: 12),

              // Likes and Published Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '❤️ ${article['positive_reactions_count'] ?? 0} Likes',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '📅 ${article['published_at'] ?? 'Unknown date'}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 'Read on Dev.to' Button
              ElevatedButton.icon(
                onPressed: () => _launchURL(article['url']),
                icon: const Icon(Icons.open_in_new),
                label: const Text('Read on Dev.to'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : screenWidth > 600 // Check if the screen width is greater than 600px
            ? _buildWebLayout(theme) // Use web layout for larger screens
            : _buildMobileLayout(
                theme); // Use mobile layout for smaller screens
  }

  /// ✅ Mobile Layout
  Widget _buildMobileLayout(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
          horizontal: 16.0, vertical: 8.0), // Adjusted padding
      itemCount: _articles.length,
      itemBuilder: (context, index) {
        final article = _articles[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (index % 7 == 0) _buildMentorCarousel(isWeb: false),
            const SizedBox(height: 16), // Added spacing between cards
            _buildArticleCard(article, theme),
          ],
        );
      },
    );
  }

  /// ✅ Web Layout (Staggered Masonry Grid)
  Widget _buildWebLayout(ThemeData theme) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 1200
        ? 4 // 4 columns for very large screens
        : 3; // 3 columns for medium-sized screens

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildMentorCarousel(isWeb: true),
          const SizedBox(height: 24),
          MasonryGridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount, // Dynamic column count
            ),
            itemCount: _articles.length,
            itemBuilder: (context, index) {
              final article = _articles[index];
              return _buildArticleCard(article, theme);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMentorCarousel({required bool isWeb}) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance.collection('mentors').limit(7).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Skeletonizer(
            enabled: true,
            child: Container(
              height: 200,
              color: Colors.grey[300],
            ),
          );
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading mentors'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No mentors available'));
        }

        final mentors = snapshot.data!.docs.toList();

        final List<Widget> carouselItems = [
          ...mentors.map((doc) {
            final mentor = doc.data() as Map<String, dynamic>;
            final mentorId = doc.id;
            return ArticleMentorCard(
              mentor: mentor,
              mentorId: mentorId,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MentorDetailsScreen(mentorId: mentorId),
                  ),
                );
              },
            );
          }).toList(),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/mentor-list-screen');
            },
            child: Container(
              width: double.infinity,
              color: Colors.transparent,
              child: const Center(
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 50,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ];

        return CarouselSlider.builder(
          itemCount: carouselItems.length,
          itemBuilder: (context, index, realIndex) {
            final displayIndex = index % carouselItems.length;
            return carouselItems[displayIndex];
          },
          options: CarouselOptions(
            height: isWeb ? 220.0 : 180.0, // Adjusted height for mobile
            viewportFraction:
                isWeb ? 0.33 : 0.8, // Adjusted viewport for mobile
            enableInfiniteScroll: true,
            autoPlay: false,
            initialPage: 0,
            scrollPhysics: const BouncingScrollPhysics(),
            padEnds: false,
          ),
        );
      },
    );
  }

  /// ✅ Dynamic Article Card with Likes on Left & 'Read More' on Right
  Widget _buildArticleCard(Map<String, dynamic> article, ThemeData theme) {
    final bool hasImage = article['cover_image'] != null;

    return Card(
      elevation: 6,
      shadowColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasImage)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                article['cover_image'],
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Article Title
                Text(
                  article['title'] ?? 'No title available',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                  maxLines: 2, // Limit title to 2 lines
                  overflow: TextOverflow.ellipsis, // Add ellipsis for overflow
                ),
                const SizedBox(height: 8),

                // Likes and 'Read More' Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Likes Text
                    Flexible(
                      child: Text(
                        '❤️ ${article['positive_reactions_count'] ?? 0} Likes',
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis, // Prevent overflow
                      ),
                    ),

                    // 'Read More' Button
                    ElevatedButton.icon(
                      onPressed: () => _showArticleDetails(context, article),
                      icon: Icon(
                        Icons.read_more,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      label: Text(
                        'Read More',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        textStyle: const TextStyle(fontSize: 14),
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
  }
}
