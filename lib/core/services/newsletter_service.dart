import 'package:flutter/material.dart';
import '../utils/backend_api_manager.dart';
import '../constants/color_palette.dart';
import '../../features/newsletters/domain/entities/newsletter.dart';
import '../../features/newsletters/domain/entities/backend_newsletter.dart';
import '../../features/newsletters/domain/entities/article.dart';
import '../../features/newsletters/domain/entities/topic.dart';
import '../../features/newsletters/domain/entities/news_headline.dart';
import '../../features/newsletters/domain/entities/source.dart';

class NewsletterService {
  static final Map<String, Topic> _topicsCache = {};
  static DateTime? _topicsCacheTime;
  static const Duration _cacheExpiry = Duration(minutes: 30);

  /// Generate a new newsletter for the current user
  static Future<void> generateNewsletter({String? topic}) async {
    try {
      // Don't pass topic parameter for 'personalizada' - let it generate personalized newsletter
      final topicToPass = (topic == 'personalizada') ? null : topic;
      await BackendApiManager.generateNewsletter(topic: topicToPass);
    } catch (e) {
      rethrow;
    }
  }

  /// Get all newsletters for the current user
  static Future<List<Newsletter>> getNewsletters({
    bool saved = false,
    String topic = ''
  }) async {
    try {
      // Get topics first (with caching)
      await _loadTopics();
      
      // Get newsletters from backend (now only returns newsletter metadata)
      final response = await BackendApiManager.getNewsletters(saved: saved, topic: topic);
      print('DEBUG - Newsletter API response: $response'); // Debug log
      final newslettersData = response['newsletters'] as List<dynamic>?;
      
      if (newslettersData == null || newslettersData.isEmpty) {
        print('DEBUG - No newsletters found in response'); // Debug log
        return [];
      }

      List<Newsletter> newsletters = [];
      
      for (var newsletterData in newslettersData) {
        try {
          print('DEBUG - Processing newsletter: $newsletterData'); // Debug log
          
          // Create backend newsletter from the simplified response
          final backendNewsletter = BackendNewsletter.fromJson(newsletterData);
          
          // For now, create newsletters without articles (articles will be loaded when needed)
          final newsletter = _convertToFrontendNewsletterWithoutArticles(backendNewsletter);
          print('DEBUG - Converted newsletter: ${newsletter.title}, Color: ${newsletter.primaryColor}'); // Debug log
          newsletters.add(newsletter);
        } catch (e) {
          print('DEBUG - Error parsing newsletter: $e'); // Debug log
          // Continue with other newsletters even if one fails
        }
      }      
      
      print('DEBUG - Total newsletters converted: ${newsletters.length}'); // Debug log
      return newsletters;
    } catch (e) {
      print('DEBUG - Error loading newsletters: $e'); // Debug log
      throw Exception('Failed to load newsletters: $e');
    }
  }

  /// Get newsletters by topic
  static Future<List<Newsletter>> getNewslettersByTopic(String topicId) async {
    try {
      print('[DEBUG] Seeking news for $topicId');
      // Get all newsletters and filter by topic
      final allNewsletters = await getNewsletters(saved: false, topic: topicId);
    
      return allNewsletters;
    } catch (e) {
      throw Exception('Failed to load newsletters for topic $topicId: $e');
    }
  }

  /// Get user topics/interests
  static Future<List<Topic>> getUserTopics() async {
    try {
      // First load all available topics
      await _loadTopics();
      
      // Get current user information to see their interests
      final userInfo = await BackendApiManager.getCurrentUser();
      final userInterests = userInfo['user']?['interests'] as List<dynamic>? ?? [];
      
      // Convert interest strings to topic IDs and get corresponding topics
      List<Topic> userTopics = [];
      
      for (String interest in userInterests.cast<String>()) {
        final topic = _topicsCache[interest];
        if (topic != null && topic.isActive) {
          userTopics.add(topic);
        }
      }
      
      return userTopics;
    } catch (e) {
      print('DEBUG - Error loading user topics: $e');
      // Return empty list if we can't load user topics
      return [];
    }
  }

  /// Get topics with their newsletter counts
  static Future<List<Topic>> getTopicsWithCounts() async {
    try {
      // First load all available topics
      await _loadTopics();
      
      // Get topics count from backend
      final response = await BackendApiManager.getNewsletterTopicsCount();
      final topicsCountData = response['topics_count'] as List<dynamic>?;
      
      if (topicsCountData == null) {
        return [];
      }

      List<Topic> topicsWithCounts = [];
      
      for (var topicCountData in topicsCountData) {
        final topicId = topicCountData['topic'] as String;
        final count = topicCountData['count'] as int;
        
        // Get topic info from cache or create default
        Topic topic = _topicsCache[topicId] ?? Topic(
          id: topicId,
          name: _formatTopicName(topicId),
          icon: 'topic',
          primaryColor: const Color(0xFF6366F1),
          secondaryColor: const Color(0xFFE0E7FF),
          isActive: true,
        );
        
        // Create a new topic with the count
        final topicWithCount = Topic(
          id: topic.id,
          name: topic.name,
          icon: topic.icon,
          primaryColor: topic.primaryColor,
          secondaryColor: topic.secondaryColor,
          isActive: topic.isActive,
          count: count,
        );
        
        topicsWithCounts.add(topicWithCount);
      }
      
      return topicsWithCounts;
    } catch (e) {
      print('DEBUG - Error loading topics with counts: $e');
      throw Exception('Failed to load topics with counts: $e');
    }
  }

  /// Load topics from backend with caching
  static Future<void> _loadTopics() async {
    // Check if cache is still valid
    if (_topicsCache.isNotEmpty && 
        _topicsCacheTime != null && 
        DateTime.now().difference(_topicsCacheTime!) < _cacheExpiry) {
      return;
    }

    try {
      final response = await BackendApiManager.getTopics();
      final topicsData = response['topics'] as List<dynamic>?;
      
      if (topicsData != null) {
        _topicsCache.clear();
        for (var topicData in topicsData) {
          try {
            final topic = Topic.fromJson(topicData);
            _topicsCache[topic.id] = topic;
          } catch (e) {
            print('DEBUG: Error parsing topic: $e');
            print('DEBUG: Topic data was: $topicData');
          }
        }
        _topicsCacheTime = DateTime.now();
      }
    } catch (e) {
      print('DEBUG: Error loading topics: $e');
      // If we can't load topics, we'll use default fallbacks
    }
  }

  /// Convert backend newsletter to frontend Newsletter model without articles
  /// Articles will be loaded separately when needed
  static Newsletter _convertToFrontendNewsletterWithoutArticles(BackendNewsletter backendNewsletter) {
    // Get topic info or use fallback
    final topicInfo = _getTopicInfo(backendNewsletter.topic);
    
    // For now, assume new data if created in the last 24 hours
    final hasNewData = DateTime.now().difference(backendNewsletter.createdAt).inHours < 24;

    return Newsletter(
      id: backendNewsletter.id,
      title: backendNewsletter.title,
      description: _generateDescription(backendNewsletter.topic, backendNewsletter.articleCount),
      icon: topicInfo.iconData,
      date: backendNewsletter.createdAt,
      hasNewData: hasNewData,
      headlines: [], // Empty for now, will be loaded when needed
      primaryColor: topicInfo.primaryColor,
      secondaryColor: topicInfo.secondaryColor,
      saved: backendNewsletter.saved,
      topic: backendNewsletter.topic
    );
  }

  /// Get newsletter articles separately
  static Future<List<NewsHeadline>> getNewsletterArticles(String newsletterId) async {
    try {
      final response = await BackendApiManager.getNewsletterArticles(newsletterId);
      final articlesData = response['articles'] as List<dynamic>?;
      
      if (articlesData == null) {
        return [];
      }

      return articlesData
          .asMap()
          .entries
          .map((entry) {
            final index = entry.key;
            final articleData = entry.value;
            final article = Article.fromJson(articleData as Map<String, dynamic>);
            return _convertToNewsHeadline(article, index);
          })
          .toList();
    } catch (e) {
      print('DEBUG - Error loading newsletter articles: $e');
      throw Exception('Failed to load newsletter articles: $e');
    }
  }

  /// Get topic information with fallback
  static Topic _getTopicInfo(String topicId) {
    print('DEBUG: Looking for topic ID: "$topicId"');
    print('DEBUG: Available topics in cache: ${_topicsCache.keys.toList()}');
    
    // Special case for "personalizada" - always use app colors
    if (topicId == 'personalizada') {
      print('DEBUG: Using app colors for personalizada topic');
      return Topic(
        id: topicId,
        name: 'Personalizada',
        icon: 'auto_awesome',
        isActive: true,
        primaryColor: AppColors.primary,
        secondaryColor: AppColors.primary.withValues(alpha: 0.1),
      );
    }
    
    if (_topicsCache.containsKey(topicId)) {
      print('DEBUG: Found topic in cache: ${_topicsCache[topicId]!.name}');
      return _topicsCache[topicId]!;
    }

    print('DEBUG: Topic not found, using fallback with app colors');
    // Fallback for unknown topics using app primary colors
    return Topic(
      id: topicId,
      name: _formatTopicName(topicId),
      icon: 'article',
      isActive: true,
      primaryColor: AppColors.primary,
      secondaryColor: AppColors.primary.withValues(alpha: 0.1),
    );
  }

  /// Format topic name for display
  static String _formatTopicName(String topicId) {
    if (topicId == 'personalizada') {
      return 'Personalizada';
    }
    
    // Capitalize first letter and replace dashes/underscores with spaces
    return topicId
        .replaceAll('-', ' ')
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isEmpty ? word : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  /// Generate description based on topic and article count
  static String _generateDescription(String topic, int articleCount) {
    if (topic == 'personalizada') {
      return 'Sua newsletter personalizada com $articleCount artigos';
    }
    
    final topicName = _formatTopicName(topic);
    return 'Últimas notícias de $topicName';
  }

  /// Convert Article to NewsHeadline
  static NewsHeadline _convertToNewsHeadline(Article article, int index) {
    print('DEBUG: Converting article "${article.title}" at index $index');
    print('DEBUG: Article imageUrl: "${article.imageUrl}"');
    print('DEBUG: Article summary: "${article.summary}"');
    print('DEBUG: Article bias_analysis_status: "${article.biasAnalysisStatus}"');
    
    // Determine if this article should have bias analysis
    // Only the first 3 articles (index 0, 1, 2) are eligible for bias analysis
    final isEligibleForBiasAnalysis = index < 3;
    final hasBiasAnalysis = article.biasAnalysisStatus == 'available' && 
                           article.biasAnalysis != null;
    
    // Process bias insights and sources by bias if available
    Map<String, int>? biasInsights;
    Map<String, List<Source>>? sourcesByBias;
    bool? isPolarized;
    
    if (isEligibleForBiasAnalysis && hasBiasAnalysis) {
      try {
        final biasAnalysis = article.biasAnalysis!;
        
        // Only process if we have actual bias data
        final hasValidBiasData = biasAnalysis.biasDistribution.centro > 0 ||
                                biasAnalysis.biasDistribution.esquerda > 0 ||
                                biasAnalysis.biasDistribution.direita > 0;
        
        if (hasValidBiasData) {
          // Convert bias distribution to the format expected by the UI
          biasInsights = {
            'Centro': biasAnalysis.biasDistribution.centro,
            'Esquerda': biasAnalysis.biasDistribution.esquerda,
            'Direita': biasAnalysis.biasDistribution.direita,
          };
          
          // Group related sources by political bias
          sourcesByBias = {
            'Centro': <Source>[],
            'Esquerda': <Source>[],
            'Direita': <Source>[],
          };
          
          // Process related sources if they exist
          if (biasAnalysis.relatedSources.isNotEmpty) {
            for (final relatedSource in biasAnalysis.relatedSources) {
              try {
                final relatedSourceUrl = relatedSource.url ?? '';
                final source = Source(
                  websiteRoot: _extractDomain(relatedSourceUrl),
                  fantasyName: relatedSource.source.isNotEmpty ? relatedSource.source : 'Fonte desconhecida',
                  articleLink: relatedSourceUrl,
                  title: relatedSource.title.isNotEmpty ? relatedSource.title : null,
                  quote: relatedSource.newsQuote.isNotEmpty ? relatedSource.newsQuote : null,
                );
                
                // Map political bias to the corresponding group
                String biasKey;
                switch (relatedSource.politicalBias.toLowerCase()) {
                  case 'centro':
                    biasKey = 'Centro';
                    break;
                  case 'esquerda':
                    biasKey = 'Esquerda';
                    break;
                  case 'direita':
                    biasKey = 'Direita';
                    break;
                  default:
                    biasKey = 'Centro'; // Default fallback
                }
                
                sourcesByBias[biasKey]?.add(source);
              } catch (e) {
                print('DEBUG: Error processing related source: $e');
                // Continue processing other sources even if one fails
              }
            }
          }
          
          // Add the article's own source to the appropriate bias group if available
          if (article.source != null && article.source!.isNotEmpty) {
            try {
              final articleSource = Source(
                websiteRoot: _extractDomain(article.url ?? ''),
                fantasyName: article.source!,
                articleLink: article.url ?? '',
                title: article.title,
                quote: article.summary,
              );
              
              // Determine which bias group to add the article's source to
              String articleBiasKey;
              if (article.politicalBias != null) {
                switch (article.politicalBias!.toLowerCase()) {
                  case 'centro':
                    articleBiasKey = 'Centro';
                    break;
                  case 'esquerda':
                    articleBiasKey = 'Esquerda';
                    break;
                  case 'direita':
                    articleBiasKey = 'Direita';
                    break;
                  default:
                    articleBiasKey = 'Centro'; // Default fallback
                }
              } else {
                articleBiasKey = 'Centro'; // Default fallback when no political bias is specified
              }
              
              // Add the article source to the appropriate bias group
              sourcesByBias[articleBiasKey]?.add(articleSource);
              
              print('DEBUG: Added article source "${article.source}" to bias group "$articleBiasKey"');
            } catch (e) {
              print('DEBUG: Error adding article source: $e');
            }
          }
          
          // Determine if the article is polarized
          // An article is considered polarized if it has sources with different political biases
          final hasLeftSources = biasAnalysis.biasDistribution.esquerda > 0;
          final hasCenterSources = biasAnalysis.biasDistribution.centro > 0;
          final hasRightSources = biasAnalysis.biasDistribution.direita > 0;
          
          // Count different bias categories
          final biasCategories = [hasLeftSources, hasCenterSources, hasRightSources]
              .where((hasSource) => hasSource)
              .length;
          
          isPolarized = biasCategories > 1; // Polarized if sources from multiple biases
        } else {
          // No valid bias data, treat as non-polarized
          isPolarized = false;
        }
      } catch (e) {
        print('DEBUG: Error processing bias analysis: $e');
        // If there's any error processing bias analysis, treat as non-polarized
        isPolarized = false;
        biasInsights = null;
        sourcesByBias = null;
      }
    } else {
      // For articles not eligible for bias analysis or without bias data
      isPolarized = false;
    }
    
    final newsHeadline = NewsHeadline(
      title: article.title,
      summary: article.summary,
      coverImage: article.imageUrl,
      mainTopics: article.bulletPointHighlights,
      isMainNews: _determineIfMainNews(article),
      sources: [
        if (article.source != null)
          Source(
            websiteRoot: _extractDomain(article.url ?? ''),
            fantasyName: article.source!,
            articleLink: article.url ?? '',
          ),
      ],
      publishedAt: article.publishedAt ?? article.createdAt,
      fullText: article.content,
      isPolarized: isPolarized,
      biasInsights: biasInsights,
      sourcesByBias: sourcesByBias,
    );
    
    print('DEBUG: Created NewsHeadline with coverImage: "${newsHeadline.coverImage}"');
    print('DEBUG: isPolarized: $isPolarized, isEligibleForBiasAnalysis: $isEligibleForBiasAnalysis');
    return newsHeadline;
  }

  /// Determine if an article should be considered main news
  static bool _determineIfMainNews(Article article) {
    // Simple heuristic: articles with more content or recent articles are main news
    return article.content.length > 500 || 
           (article.publishedAt != null && 
            DateTime.now().difference(article.publishedAt!).inHours < 12);
  }

  /// Extract domain from URL
  static String _extractDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host;
    } catch (e) {
      return 'unknown';
    }
  }

  /// Clear topics cache (useful for testing or forcing refresh)
  static void clearTopicsCache() {
    _topicsCache.clear();
    _topicsCacheTime = null;
  }

  /// Toggle save status for a newsletter
  static Future<bool> toggleNewsletterSave(String newsletterId) async {
    try {
      final response = await BackendApiManager.toggleNewsletterSave(newsletterId);
      
      // Return the new saved status from the API response
      return response['saved'] as bool? ?? false;
    } catch (e) {
      rethrow;
    }
  }
}
