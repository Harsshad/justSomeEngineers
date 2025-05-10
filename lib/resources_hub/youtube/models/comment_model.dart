class Comment {
  final String authorDisplayName;
  final String authorProfileImageUrl;
  final String textDisplay;

  Comment({
    required this.authorDisplayName,
    required this.authorProfileImageUrl,
    required this.textDisplay,
  });

  factory Comment.fromMap(Map<String, dynamic> map) {
    final snippet = map['snippet']['topLevelComment']['snippet'];
    return Comment(
      authorDisplayName: snippet['authorDisplayName'] ?? '',
      authorProfileImageUrl: snippet['authorProfileImageUrl'] ?? '',
      textDisplay: snippet['textDisplay'] ?? '',
    );
  }

  static List<Comment> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => Comment.fromMap(json)).toList();
  }
}
