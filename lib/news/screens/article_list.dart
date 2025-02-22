import 'package:codefusion/mentorship/screens/mentor_detail_screen.dart';
import 'package:codefusion/news/services/article_functions.dart';
import 'package:codefusion/news/widgets/article_mentor_card.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skeletonizer/skeletonizer.dart';

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
        _articles = [];
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
                article['title'] ?? 'No title available',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                article['description'] ?? 'No description available',
                style: TextStyle(
                    fontSize: 14, color: Theme.of(context).colorScheme.primary),
                // maxLines: 7,
              ),
              const SizedBox(height: 12),
              Text(
                'Published on: ${article['published_at'] ?? 'Unknown date'}',
                style: TextStyle(
                    fontSize: 12, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.link),
                label: const Text("Read Full Article"), //when clicked on this button it doesnt take to the designated website 
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
  final Uri uri = Uri.parse(url);

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not launch the article URL')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _articles.isEmpty
        ? Skeletonizer(
            enabled: true,
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: 5,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Card(
                      margin: const EdgeInsets.only(bottom: 22),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: Container(
                              height: 180,
                              width: double.infinity,
                              color: Colors.grey[300],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 20,
                                  width: 150,
                                  color: Colors.grey[300],
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  height: 14,
                                  width: double.infinity,
                                  color: Colors.grey[300],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      height: 14,
                                      width: 100,
                                      color: Colors.grey[300],
                                    ),
                                    Container(
                                      height: 30,
                                      width: 100,
                                      color: Colors.grey[300],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: _articles.length,
            itemBuilder: (context, index) {
              final article = _articles[index];
              return Column(
                children: [
                  if (index % 7 == 0)
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('mentors')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Skeletonizer(
                            enabled: true,
                            child: Container(
                              height: 200,
                              color: Colors.grey[300],
                            ),
                          );
                        }
                        if (snapshot.hasError) {
                          return const Center(
                              child: Text('Error loading mentors'));
                        }
                        if (!snapshot.hasData ||
                            snapshot.data!.docs.isEmpty) {
                          return const Center(
                              child: Text('No mentors available'));
                        }

                        final mentors = snapshot.data!.docs;
                        return Column(
                          children: [
                            CarouselSlider(
                              options: CarouselOptions(height: 200.0),
                              items: [
                                ...mentors.take(7).map((doc) {
                                  final mentor = doc.data() as Map<String, dynamic>;
                                  final mentorId = doc.id;
                                  return Builder(
                                    builder: (BuildContext context) {
                                      return ArticleMentorCard(
                                        mentor: mentor,
                                        mentorId: mentorId,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  MentorDetailsScreen(
                                                      mentorId: mentorId),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  );
                                }).toList(),
                                Builder(
                                  builder: (BuildContext context) {
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.pushNamed(
                                            context, '/mentor-list-screen');
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
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                        );
                      },
                    ),
                  Card(
                    margin: const EdgeInsets.only(bottom: 22),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (article['cover_image'] != null)
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(
                                12,
                              ),
                            ),
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
                                article['title'] ?? 'No title available',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.inversePrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                article['description'] ??
                                    'No description available',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: theme.colorScheme.primary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '❤️ ${article['positive_reactions_count'] ?? 0} Likes',
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          theme.colorScheme.secondary,
                                    ),
                                    onPressed: () =>
                                        _showArticleDetails(context, article),
                                    child: Text(
                                      'Read More 📖',
                                      style: TextStyle(
                                          color:
                                              theme.colorScheme.inversePrimary),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
  }
}