// Related classes for bias analysis
class BiasDistribution {
  final int centro;
  final int direita;
  final int esquerda;

  BiasDistribution({
    required this.centro,
    required this.direita,
    required this.esquerda,
  });

  factory BiasDistribution.fromJson(Map<String, dynamic> json) {
    return BiasDistribution(
      centro: json['centro'] as int? ?? 0,
      direita: json['direita'] as int? ?? 0,
      esquerda: json['esquerda'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'centro': centro,
      'direita': direita,
      'esquerda': esquerda,
    };
  }
}

class RelatedSource {
  final String articleId;
  final String createdAt;
  final String id;
  final String newsQuote;
  final String politicalBias;
  final String publishedAt;
  final String source;
  final String title;
  final String? url;

  RelatedSource({
    required this.articleId,
    required this.createdAt,
    required this.id,
    required this.newsQuote,
    required this.politicalBias,
    required this.publishedAt,
    required this.source,
    required this.title,
    this.url,
  });

  factory RelatedSource.fromJson(Map<String, dynamic> json) {
    return RelatedSource(
      articleId: json['article_id'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      id: json['id'] as String? ?? '',
      newsQuote: json['news_quote'] as String? ?? '',
      politicalBias: json['political_bias'] as String? ?? 'centro',
      publishedAt: json['published_at'] as String? ?? '',
      source: json['source'] as String? ?? '',
      title: json['title'] as String? ?? '',
      url: json['url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'article_id': articleId,
      'created_at': createdAt,
      'id': id,
      'news_quote': newsQuote,
      'political_bias': politicalBias,
      'published_at': publishedAt,
      'source': source,
      'title': title,
      'url': url,
    };
  }
}

class BiasAnalysis {
  final BiasDistribution biasDistribution;
  final Map<String, double> distributionSummary;
  final List<RelatedSource> relatedSources;
  final String status;
  final int totalSources;

  BiasAnalysis({
    required this.biasDistribution,
    required this.distributionSummary,
    required this.relatedSources,
    required this.status,
    required this.totalSources,
  });

  factory BiasAnalysis.fromJson(Map<String, dynamic> json) {
    try {
      return BiasAnalysis(
        biasDistribution: json['bias_distribution'] != null 
            ? BiasDistribution.fromJson(json['bias_distribution'] as Map<String, dynamic>)
            : BiasDistribution(centro: 0, direita: 0, esquerda: 0),
        distributionSummary: json['distribution_summary'] != null 
            ? Map<String, double>.from(json['distribution_summary'] as Map<String, dynamic>)
            : <String, double>{},
        relatedSources: json['related_sources'] != null 
            ? (json['related_sources'] as List<dynamic>)
                .map((e) => RelatedSource.fromJson(e as Map<String, dynamic>))
                .toList()
            : <RelatedSource>[],
        status: json['status'] as String? ?? 'unavailable',
        totalSources: json['total_sources'] as int? ?? 0,
      );
    } catch (e) {
      // Return a default BiasAnalysis if parsing fails
      return BiasAnalysis(
        biasDistribution: BiasDistribution(centro: 0, direita: 0, esquerda: 0),
        distributionSummary: <String, double>{},
        relatedSources: <RelatedSource>[],
        status: 'error',
        totalSources: 0,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'bias_distribution': biasDistribution.toJson(),
      'distribution_summary': distributionSummary,
      'related_sources': relatedSources.map((e) => e.toJson()).toList(),
      'status': status,
      'total_sources': totalSources,
    };
  }
}

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
  // Bias analysis fields
  final String? biasAnalysisStatus;
  final BiasAnalysis? biasAnalysis;

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
    this.biasAnalysisStatus,
    this.biasAnalysis,
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
      biasAnalysisStatus: json['bias_analysis_status'] as String?,
      biasAnalysis: json['bias_analysis'] != null 
          ? BiasAnalysis.fromJson(json['bias_analysis'] as Map<String, dynamic>)
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
      'bias_analysis_status': biasAnalysisStatus,
      'bias_analysis': biasAnalysis?.toJson(),
    };
  }
}
