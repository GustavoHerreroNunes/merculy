class Article {
  final String id;
  final String title;
  final String content;
  final String? summary;
  final String? imageUrl;
  final String? source;
  final String? url;
  final String topic;
  final String? politicalBias;
  final List<String> bulletPointHighlights;
  final DateTime createdAt;
  final DateTime? publishedAt;

  Article({
    required this.id,
    required this.title,
    required this.content,
    this.summary,
    this.imageUrl,
    this.source,
    this.url,
    required this.topic,
    this.politicalBias,
    required this.bulletPointHighlights,
    required this.createdAt,
    this.publishedAt,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      summary: json['summary'] as String?,
      imageUrl: json['image_url'] as String?,
      source: json['source'] as String?,
      url: json['url'] as String?,
      topic: json['topic'] as String,
      politicalBias: json['political_bias'] as String?,
      bulletPointHighlights: (json['bullet_point_highlights'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      createdAt: DateTime.parse(json['created_at'] as String),
      publishedAt: json['published_at'] != null 
          ? DateTime.parse(json['published_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'summary': summary,
      'image_url': imageUrl,
      'source': source,
      'url': url,
      'topic': topic,
      'political_bias': politicalBias,
      'bullet_point_highlights': bulletPointHighlights,
      'created_at': createdAt.toIso8601String(),
      'published_at': publishedAt?.toIso8601String(),
    };
  }
}
