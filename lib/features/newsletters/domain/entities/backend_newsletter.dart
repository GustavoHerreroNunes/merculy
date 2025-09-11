import 'article.dart';

class BackendNewsletter {
  final String id;
  final String title;
  final String topic;
  final String userId;
  final int articleCount;
  final List<String> articleIds; // Changed from articles to articleIds for clarity
  final DateTime createdAt;
  final bool saved;

  BackendNewsletter({
    required this.id,
    required this.title,
    required this.topic,
    required this.userId,
    required this.articleCount,
    required this.articleIds,
    required this.createdAt,
    required this.saved,
  });

  factory BackendNewsletter.fromJson(Map<String, dynamic> json) {
    return BackendNewsletter(
      id: json['id'] as String,
      title: json['title'] as String,
      topic: json['topic'] as String,
      userId: json['user_id'] as String,
      articleCount: json['article_count'] as int,
      articleIds: (json['articles'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      saved: json['saved'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'topic': topic,
      'user_id': userId,
      'article_count': articleCount,
      'articles': articleIds,
      'created_at': createdAt.toIso8601String(),
      'saved': saved
    };
  }
}

class NewsletterResponse {
  final BackendNewsletter newsletter;
  final List<Article> articles;

  NewsletterResponse({
    required this.newsletter,
    required this.articles,
  });

  factory NewsletterResponse.fromJson(Map<String, dynamic> json) {
    // Handle the new API structure where newsletters come without articles
    return NewsletterResponse(
      newsletter: BackendNewsletter.fromJson(json),
      articles: [], // Articles will be loaded separately
    );
  }
  
  // Create NewsletterResponse with separate articles
  factory NewsletterResponse.withArticles({
    required BackendNewsletter newsletter,
    required List<Article> articles,
  }) {
    return NewsletterResponse(
      newsletter: newsletter,
      articles: articles,
    );
  }
}
