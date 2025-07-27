import 'source.dart';

class NewsHeadline {
  final String title;
  final String? summary;
  final String? coverImage;
  final List<String>? mainTopics;
  final bool isMainNews;
  final List<Source> sources;
  final DateTime? publishedAt;

  NewsHeadline({
    required this.title,
    this.summary,
    this.coverImage,
    this.mainTopics,
    required this.isMainNews,
    required this.sources,
    this.publishedAt,
  });

  factory NewsHeadline.fromJson(Map<String, dynamic> json) {
    return NewsHeadline(
      title: json['title'] as String,
      summary: json['summary'] as String?,
      coverImage: json['coverImage'] as String?,
      mainTopics: (json['mainTopics'] as List<dynamic>?)?.cast<String>(),
      isMainNews: json['isMainNews'] as bool,
      sources: (json['sources'] as List<dynamic>)
          .map((source) => Source.fromJson(source as Map<String, dynamic>))
          .toList(),
      publishedAt: json['publishedAt'] != null 
          ? DateTime.parse(json['publishedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'summary': summary,
      'coverImage': coverImage,
      'mainTopics': mainTopics,
      'isMainNews': isMainNews,
      'sources': sources.map((source) => source.toJson()).toList(),
      'publishedAt': publishedAt?.toIso8601String(),
    };
  }
}
