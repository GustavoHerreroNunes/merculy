import 'dart:convert';
import 'dart:html' as html;
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

class WebImageCacheService {
  static const String _storagePrefix = 'merculy_image_';
  static const int _maxStorageSize = 50 * 1024 * 1024; // 50MB limit
  
  static bool _isInitialized = false;
  
  /// Initialize the cache (enhanced for web)
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    debugPrint('🚀 WebImageCacheService: Initializing for web platform...');
    _isInitialized = true;
    
    // Check localStorage availability and quota
    try {
      final storage = html.window.localStorage;
      final testKey = '${_storagePrefix}test';
      storage[testKey] = 'test';
      storage.remove(testKey);
      debugPrint('✅ WebImageCacheService: localStorage available');
      
      // Log current cache size
      final currentSize = await getCacheSize();
      debugPrint('📊 WebImageCacheService: Current cache size: ${(currentSize / 1024).toStringAsFixed(1)} KB');
      
    } catch (e) {
      debugPrint('❌ WebImageCacheService: localStorage not available: $e');
    }
  }
  
  /// Get cached image data as base64 string
  static Future<String?> getCachedImageData(String imageUrl) async {
    try {
      final cacheKey = _getCacheKey(imageUrl);
      final storage = html.window.localStorage;
      final cachedData = storage[cacheKey];
      
      if (cachedData != null) {
        debugPrint('✅ WebImageCacheService: Found cached image for: $imageUrl');
        return cachedData;
      }
      
      debugPrint('❌ WebImageCacheService: No cached image for: $imageUrl');
      return null;
    } catch (e) {
      debugPrint('❌ WebImageCacheService: Error getting cached image: $e');
      return null;
    }
  }
  
  /// Download and cache image in localStorage as base64
  static Future<String?> downloadAndCacheImage(String imageUrl) async {
    try {
      debugPrint('📥 WebImageCacheService: Starting download for: $imageUrl');
      
      // Check if already cached first
      final cached = await getCachedImageData(imageUrl);
      if (cached != null) {
        debugPrint('✅ WebImageCacheService: Image already cached');
        return cached;
      }
      
      // Try multiple methods to bypass CORS
      String? dataUrl = await _tryDownloadMethods(imageUrl);
      
      if (dataUrl != null) {
        // Cache the successful result
        await _cacheImageData(imageUrl, dataUrl);
        debugPrint('✅ WebImageCacheService: Successfully cached: $imageUrl');
        return dataUrl;
      }
      
      debugPrint('❌ WebImageCacheService: All download methods failed for: $imageUrl');
      return null;
      
    } catch (e) {
      debugPrint('❌ WebImageCacheService: Error downloading image: $e');
      return null;
    }
  }
  
  /// Try multiple download methods to bypass CORS
  static Future<String?> _tryDownloadMethods(String imageUrl) async {
    // Method 1: Try direct HTTP client (works for some CORS-enabled sites)
    try {
      debugPrint('🔄 WebImageCacheService: Trying HTTP client method...');
      final response = await http.get(
        Uri.parse(imageUrl),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          'Accept': 'image/*,*/*;q=0.8',
          'Accept-Encoding': 'gzip, deflate, br',
          'Accept-Language': 'pt-BR,pt;q=0.9,en;q=0.8',
          'Referer': 'https://g1.globo.com',
          'Origin': 'https://g1.globo.com',
        },
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final base64Data = base64Encode(response.bodyBytes);
        final mimeType = _getMimeType(imageUrl, response.headers['content-type']);
        final dataUrl = 'data:$mimeType;base64,$base64Data';
        debugPrint('✅ WebImageCacheService: HTTP client method succeeded');
        return dataUrl;
      } else {
        debugPrint('❌ WebImageCacheService: HTTP client failed with status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ WebImageCacheService: HTTP client method failed: $e');
    }
    
    // Method 2: Try using Image element (works for some cases)
    try {
      debugPrint('🔄 WebImageCacheService: Trying Image element method...');
      final imageElement = html.ImageElement();
      imageElement.crossOrigin = 'anonymous';
      
      final completer = Completer<String?>();
      
      imageElement.onLoad.listen((_) {
        try {
          final canvas = html.CanvasElement();
          canvas.width = imageElement.naturalWidth;
          canvas.height = imageElement.naturalHeight;
          
          final context = canvas.context2D;
          context.drawImage(imageElement, 0, 0);
          
          final dataUrl = canvas.toDataUrl('image/jpeg', 0.8);
          debugPrint('✅ WebImageCacheService: Image element method succeeded');
          completer.complete(dataUrl);
        } catch (e) {
          debugPrint('❌ WebImageCacheService: Canvas conversion failed: $e');
          completer.complete(null);
        }
      });
      
      imageElement.onError.listen((_) {
        debugPrint('❌ WebImageCacheService: Image element method failed');
        completer.complete(null);
      });
      
      imageElement.src = imageUrl;
      
      return await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('⏱️ WebImageCacheService: Image element method timed out');
          return null;
        },
      );
    } catch (e) {
      debugPrint('❌ WebImageCacheService: Image element method failed: $e');
    }
    
    // Method 3: Try CORS proxy (fallback)
    try {
      debugPrint('🔄 WebImageCacheService: Trying CORS proxy method...');
      final proxyUrl = 'https://cors-anywhere.herokuapp.com/$imageUrl';
      final response = await http.get(
        Uri.parse(proxyUrl),
        headers: {
          'X-Requested-With': 'XMLHttpRequest',
        },
      ).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        final base64Data = base64Encode(response.bodyBytes);
        final mimeType = _getMimeType(imageUrl, response.headers['content-type']);
        final dataUrl = 'data:$mimeType;base64,$base64Data';
        debugPrint('✅ WebImageCacheService: CORS proxy method succeeded');
        return dataUrl;
      } else {
        debugPrint('❌ WebImageCacheService: CORS proxy failed with status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ WebImageCacheService: CORS proxy method failed: $e');
    }
    
    return null;
  }
  
  /// Cache image data in localStorage
  static Future<void> _cacheImageData(String imageUrl, String dataUrl) async {
    try {
      final cacheKey = _getCacheKey(imageUrl);
      final storage = html.window.localStorage;
      
      // Check if we have space (basic quota management)
      final currentSize = await getCacheSize();
      final dataSize = dataUrl.length;
      
      if (currentSize + dataSize > _maxStorageSize) {
        debugPrint('⚠️ WebImageCacheService: Cache full, clearing old entries...');
        await _clearOldestEntries();
      }
      
      storage[cacheKey] = dataUrl;
      debugPrint('💾 WebImageCacheService: Cached image data (${(dataSize / 1024).toStringAsFixed(1)} KB)');
      
    } catch (e) {
      debugPrint('❌ WebImageCacheService: Error caching image data: $e');
    }
  }
  
  /// Generate cache key from URL
  static String _getCacheKey(String imageUrl) {
    final bytes = utf8.encode(imageUrl);
    final hash = sha256.convert(bytes);
    return '$_storagePrefix${hash.toString().substring(0, 16)}';
  }
  
  /// Get MIME type from response headers or URL
  static String _getMimeType(String imageUrl, String? contentType) {
    if (contentType != null && contentType.startsWith('image/')) {
      return contentType;
    }
    
    // Guess from URL extension
    final uri = Uri.parse(imageUrl);
    final path = uri.path.toLowerCase();
    
    if (path.endsWith('.jpg') || path.endsWith('.jpeg')) return 'image/jpeg';
    if (path.endsWith('.png')) return 'image/png';
    if (path.endsWith('.gif')) return 'image/gif';
    if (path.endsWith('.webp')) return 'image/webp';
    
    return 'image/jpeg'; // Default fallback
  }
  
  /// Clear all cached images
  static Future<void> clearCache() async {
    try {
      debugPrint('🧹 WebImageCacheService: Clearing all cached images...');
      final storage = html.window.localStorage;
      final keysToRemove = <String>[];
      
      // Find all cache keys
      for (int i = 0; i < storage.length; i++) {
        final key = storage.keys.elementAt(i);
        if (key.startsWith(_storagePrefix)) {
          keysToRemove.add(key);
        }
      }
      
      // Remove all cache entries
      for (final key in keysToRemove) {
        storage.remove(key);
      }
      
      debugPrint('✅ WebImageCacheService: Cleared ${keysToRemove.length} cached images');
    } catch (e) {
      debugPrint('❌ WebImageCacheService: Error clearing cache: $e');
    }
  }
  
  /// Clear oldest entries when cache is full
  static Future<void> _clearOldestEntries() async {
    try {
      final storage = html.window.localStorage;
      final cacheKeys = <String>[];
      
      // Collect cache keys (we can't easily determine age, so remove half)
      for (int i = 0; i < storage.length; i++) {
        final key = storage.keys.elementAt(i);
        if (key.startsWith(_storagePrefix)) {
          cacheKeys.add(key);
        }
      }
      
      // Remove half of the entries
      final removeCount = (cacheKeys.length * 0.5).ceil();
      for (int i = 0; i < removeCount && i < cacheKeys.length; i++) {
        storage.remove(cacheKeys[i]);
      }
      
      debugPrint('🧹 WebImageCacheService: Cleared $removeCount old entries');
    } catch (e) {
      debugPrint('❌ WebImageCacheService: Error clearing old entries: $e');
    }
  }
  
  /// Get total cache size in bytes
  static Future<int> getCacheSize() async {
    try {
      final storage = html.window.localStorage;
      int totalSize = 0;
      
      for (int i = 0; i < storage.length; i++) {
        final key = storage.keys.elementAt(i);
        if (key.startsWith(_storagePrefix)) {
          final value = storage[key];
          if (value != null) {
            totalSize += value.length;
          }
        }
      }
      
      return totalSize;
    } catch (e) {
      debugPrint('❌ WebImageCacheService: Error calculating cache size: $e');
      return 0;
    }
  }
  
  /// Get cached image count
  static Future<int> getCachedImageCount() async {
    try {
      final storage = html.window.localStorage;
      int count = 0;
      
      for (int i = 0; i < storage.length; i++) {
        final key = storage.keys.elementAt(i);
        if (key.startsWith(_storagePrefix)) {
          count++;
        }
      }
      
      return count;
    } catch (e) {
      debugPrint('❌ WebImageCacheService: Error counting cached images: $e');
      return 0;
    }
  }
  
  /// Get cache information for debugging
  static Future<Map<String, dynamic>> getCacheInfo() async {
    try {
      final count = await getCachedImageCount();
      final size = await getCacheSize();
      
      return {
        'exists': true,
        'storage': 'localStorage',
        'fileCount': count,
        'sizeBytes': size,
        'sizeMB': (size / 1024 / 1024).toStringAsFixed(2),
        'maxSizeMB': (_maxStorageSize / 1024 / 1024).toStringAsFixed(0),
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'exists': false,
      };
    }
  }
  
  /// Check if image is cached
  static Future<bool> isImageCached(String url) async {
    final cached = await getCachedImageData(url);
    return cached != null;
  }
}
