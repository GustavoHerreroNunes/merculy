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
  static Future<void> generateNewsletter() async {
    try {
      await BackendApiManager.generateNewsletter();
    } catch (e) {
      rethrow;
    }
  }

  /// Get all newsletters for the current user
  static Future<List<Newsletter>> getNewsletters({
    bool saved = false
  }) async {
    try {
      // Get topics first (with caching)
      await _loadTopics();
      
      // Get newsletters from backend
      final response = await BackendApiManager.getNewsletters(saved: saved);
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
          final newsletterResponse = NewsletterResponse.fromJson(newsletterData);
          
          // Debug articles in this newsletter
          print('DEBUG - Newsletter has ${newsletterResponse.articles.length} articles');
          for (int i = 0; i < newsletterResponse.articles.take(3).length; i++) {
            final article = newsletterResponse.articles[i];
            print('DEBUG - Article $i: "${article.title}"');
            print('DEBUG - Article $i imageUrl: "${article.imageUrl}"');
          }
          
          // Debug raw article data from backend
          final articlesRawData = newsletterData['articles'] as List<dynamic>?;
          if (articlesRawData != null && articlesRawData.isNotEmpty) {
            print('DEBUG - Raw article 0 data: ${articlesRawData[0]}');
            print('DEBUG - Raw article 0 image_url field: ${articlesRawData[0]['image_url']}');
          }
          
          final newsletter = _convertToFrontendNewsletter(newsletterResponse);
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

  /// Convert backend newsletter response to frontend Newsletter model
  static Newsletter _convertToFrontendNewsletter(NewsletterResponse response) {
    final backendNewsletter = response.newsletter;
    final articles = response.articles;
    
    // Get topic info or use fallback
    final topicInfo = _getTopicInfo(backendNewsletter.topic);
    
    // Convert articles to NewsHeadlines
    final headlines = articles.map((article) => _convertToNewsHeadline(article)).toList();
    
    // Determine if there are new articles (created in the last 24 hours)
    final hasNewData = articles.any((article) => 
      DateTime.now().difference(article.createdAt).inHours < 24
    );

    return Newsletter(
      id: backendNewsletter.id,
      title: backendNewsletter.title,
      description: _generateDescription(backendNewsletter.topic, articles.length),
      icon: topicInfo.iconData,
      date: backendNewsletter.createdAt,
      hasNewData: hasNewData,
      headlines: headlines,
      primaryColor: topicInfo.primaryColor,
      secondaryColor: topicInfo.secondaryColor,
      saved: backendNewsletter.saved
    );
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
  static NewsHeadline _convertToNewsHeadline(Article article) {
    print('DEBUG: Converting article "${article.title}"');
    print('DEBUG: Article imageUrl: "${article.imageUrl}"');
    print('DEBUG: Article summary: "${article.summary}"');
    
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
      isPolarized: article.politicalBias != null,
    );
    
    print('DEBUG: Created NewsHeadline with coverImage: "${newsHeadline.coverImage}"');
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
