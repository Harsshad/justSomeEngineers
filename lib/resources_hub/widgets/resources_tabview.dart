import 'package:codefusion/resources_hub/services/devto_service.dart';
import 'package:codefusion/resources_hub/services/medium_service.dart';
import 'package:flutter/material.dart';
import 'package:codefusion/resources_hub/models/article_list.dart';
import 'package:codefusion/resources_hub/models/devto_article_list.dart';
import 'package:codefusion/resources_hub/models/video_list.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class ResourcesTabView extends StatelessWidget {
  final TabController tabController;
  final bool isLoading;
  final List<Article> articles;
  final List<DevToArticle> devToArticles;
  final List<Video> videos;
  final int selectedIndex;

  const ResourcesTabView({
    Key? key,
    required this.tabController,
    required this.isLoading,
    required this.articles,
    required this.devToArticles,
    required this.videos,
    required this.selectedIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return selectedIndex == 0
        ? isLoading
            ? Skeletonizer(
                enabled: true,
                child: ListView.builder(
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
            : TabBarView(
                controller: tabController,
                children: [
                  ArticleList(articles: articles),
                  DevToArticleList(devToArticles: devToArticles),
                ],
              )
        : selectedIndex == 1
            ? isLoading
                ? Skeletonizer(
                    enabled: true,
                    child: ListView.builder(
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
                : VideoList(videos: videos)
            : Container();
  }
}
