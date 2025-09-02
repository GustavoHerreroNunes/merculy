import 'article.dart';

class BackendNewsletter {
  final String id;
  final String title;
  final String topic;
  final String userId;
  final int articleCount;
  final List<String> articles;
  final DateTime createdAt;

  BackendNewsletter({
    required this.id,
    required this.title,
    required this.topic,
    required this.userId,
    required this.articleCount,
    required this.articles,
    required this.createdAt,
  });

  factory BackendNewsletter.fromJson(Map<String, dynamic> json) {
    return BackendNewsletter(
      id: json['id'] as String,
      title: json['title'] as String,
      topic: json['topic'] as String,
      userId: json['user_id'] as String,
      articleCount: json['article_count'] as int,
      articles: (json['articles'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
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
      'articles': articles,
      'created_at': createdAt.toIso8601String(),
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
    return NewsletterResponse(
      newsletter: BackendNewsletter.fromJson(json['newsletter'] as Map<String, dynamic>),
      articles: (json['articles'] as List<dynamic>?)
          ?.map((article) => Article.fromJson(article as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}
