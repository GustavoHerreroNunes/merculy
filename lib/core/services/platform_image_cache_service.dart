import 'package:flutter/foundation.dart';
import 'package:merculy/core/services/web_image_cache_service.dart';

// Platform-aware imports
import 'image_cache_service.dart' if (dart.library.html) 'web_image_cache_service.dart';

class PlatformImageCacheService {
  /// Initialize the cache service based on platform
  static Future<void> initialize() async {
    if (kIsWeb) {
      print('🌐 PlatformImageCacheService: Using web implementation');
      await WebImageCacheService.initialize();
    } else {
      print('📱 PlatformImageCacheService: Using mobile/desktop implementation');
      await ImageCacheService.initialize();
    }
  }

  /// Check if image is cached
  static Future<bool> isImageCached(String url) async {
    if (kIsWeb) {
      return await WebImageCacheService.isImageCached(url);
    } else {
      return await ImageCacheService.isImageCached(url);
    }
  }

  /// Download and cache image
  static Future<dynamic> downloadAndCacheImage(String url) async {
    if (kIsWeb) {
      return await WebImageCacheService.downloadAndCacheImage(url);
    } else {
      return await ImageCacheService.downloadAndCacheImage(url);
    }
  }

  /// Clear all cached images
  static Future<void> clearCache() async {
    if (kIsWeb) {
      await WebImageCacheService.clearCache();
    } else {
      await ImageCacheService.clearCache();
    }
  }

  /// Get cache information
  static Future<Map<String, dynamic>> getCacheInfo() async {
    if (kIsWeb) {
      return await WebImageCacheService.getCacheInfo();
    } else {
      return await ImageCacheService.getCacheInfo();
    }
  }
}
