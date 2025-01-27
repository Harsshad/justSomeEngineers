import 'package:codefusion/mentorship/screens/mentor_detail_screen.dart';
import 'package:codefusion/news/services/article_functions.dart';
import 'package:codefusion/news/widgets/article_mentor_card.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ArticleList extends StatefulWidget {
  const ArticleList({Key? key}) : super(key: key);

  @override
  ArticleListState createState() => ArticleListState();
}

class ArticleListState extends State<ArticleList> {
  static List<dynamic> _articles = [];
  List<Map<String, dynamic>> _mentors = [];

  @override
  void initState() {
    super.initState();
    _fetchArticles(" ");
    _fetchMentors();
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

  void _fetchMentors() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('mentors').get();
      final mentors = snapshot.docs.map((doc) => doc.data()).toList();
      setState(() {
        _mentors = mentors;
      });
    } catch (e) {
      print('Error fetching mentors: $e');
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
    final theme = Theme.of(context);
    return _articles.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: _articles.length,
            itemBuilder: (context, index) {
              final article = _articles[index];
              return Column(
                children: [
                  if (index % 7 == 0 && _mentors.isNotEmpty)
                    Column(
                      children: [
                        CarouselSlider(
                          options: CarouselOptions(height: 200.0),
                          items: [
                            ..._mentors.take(7).map((mentor) {
                              return Builder(
                                builder: (BuildContext context) {
                                  return ArticleMentorCard(
                                    mentor: mentor,
                                    mentorId: mentor['uid'] ?? '',
                                    onTap: () {
                                      // Navigator.push(
                                      //   context,
                                      //   MaterialPageRoute(
                                      //     builder: (context) => MentorDetailsScreen(mentorId: mentor['uid']),
                                      //   ),
                                      // );
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
                    ),
                  Card(
                    margin: const EdgeInsets.only(bottom: 22),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      // bordercolor: theme.colorScheme.secondary,
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
