import 'source.dart';

class NewsHeadline {
  final String title;
  final String? summary;
  final String? coverImage;
  final List<String>? mainTopics;
  final bool isMainNews;
  final List<Source> sources;
  final DateTime? publishedAt;
  final String? fullText;
  final bool? isPolarized;
  final Map<String, int>? biasInsights;
  final Map<String, List<Source>>? sourcesByBias;

  NewsHeadline({
    required this.title,
    this.summary,
    this.coverImage,
    this.mainTopics,
    required this.isMainNews,
    required this.sources,
    this.publishedAt,
    this.fullText,
    this.isPolarized,
    this.biasInsights,
    this.sourcesByBias,
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
      fullText: json['fullText'] as String?,
      isPolarized: json['isPolarized'] as bool?,
      biasInsights: (json['biasInsights'] as Map<String, dynamic>?)?.cast<String, int>(),
      sourcesByBias: (json['sourcesByBias'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(
          key,
          (value as List<dynamic>)
              .map((source) => Source.fromJson(source as Map<String, dynamic>))
              .toList(),
        ),
      ),
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
      'fullText': fullText,
      'isPolarized': isPolarized,
      'biasInsights': biasInsights,
      'sourcesByBias': sourcesByBias?.map(
        (key, value) => MapEntry(
          key,
          value.map((source) => source.toJson()).toList(),
        ),
      ),
    };
  }
}
