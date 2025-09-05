import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'dart:convert';

// Web-specific imports
import 'dart:html' as html show window;

// Mobile-specific imports  
import 'package:path_provider/path_provider.dart';

class ImageCacheService {
  static Directory? _cacheDirectory;
  static const String _cacheFolderName = 'merculy_image_cache';

  /// Initialize the cache directory
  static Future<void> initialize() async {
    try {
      print('🚀 ImageCacheService: Initializing cache directory...');
      final tempDir = await getTemporaryDirectory();
      print('📁 ImageCacheService: Temp directory: ${tempDir.path}');
      
      _cacheDirectory = Directory('${tempDir.path}/$_cacheFolderName');
      print('📁 ImageCacheService: Cache directory: ${_cacheDirectory!.path}');
      
      if (!await _cacheDirectory!.exists()) {
        print('🏗️ ImageCacheService: Creating cache directory...');
        await _cacheDirectory!.create(recursive: true);
        print('✅ ImageCacheService: Cache directory created successfully');
      } else {
        print('✅ ImageCacheService: Cache directory already exists');
      }
      
      // Show cache info
      final cacheInfo = await getCacheInfo();
      print('📊 ImageCacheService: Cache info: $cacheInfo');
    } catch (e) {
      print('💥 ImageCacheService: Failed to initialize image cache directory: $e');
    }
  }

  /// Generate a safe filename from URL
  static String _generateCacheFileName(String url) {
    final bytes = utf8.encode(url);
    final digest = sha256.convert(bytes);
    return '${digest.toString().substring(0, 16)}.jpg';
  }

  /// Get the cached file path for a URL
  static String? _getCacheFilePath(String url) {
    if (_cacheDirectory == null) return null;
    final fileName = _generateCacheFileName(url);
    return '${_cacheDirectory!.path}/$fileName';
  }

  /// Check if image is cached locally
  static Future<bool> isImageCached(String url) async {
    if (_cacheDirectory == null) return false;
    final filePath = _getCacheFilePath(url);
    if (filePath == null) return false;
    
    final file = File(filePath);
    return await file.exists();
  }

  /// Get cached image file
  static Future<File?> getCachedImageFile(String url) async {
    if (await isImageCached(url)) {
      final filePath = _getCacheFilePath(url);
      if (filePath != null) {
        return File(filePath);
      }
    }
    return null;
  }

  /// Download and cache image from URL
  static Future<File?> downloadAndCacheImage(String url) async {
    try {
      print('📥 ImageCacheService: Starting download for: $url');
      
      if (_cacheDirectory == null) {
        print('⚠️ ImageCacheService: Cache directory not initialized, initializing...');
        await initialize();
        if (_cacheDirectory == null) {
          print('❌ ImageCacheService: Failed to initialize cache directory');
          return null;
        }
      }

      // Check if already cached
      print('🔍 ImageCacheService: Checking if image already cached...');
      final cachedFile = await getCachedImageFile(url);
      if (cachedFile != null) {
        print('✅ ImageCacheService: Image already cached at: ${cachedFile.path}');
        return cachedFile;
      }

      final fileName = _generateCacheFileName(url);
      final filePath = _getCacheFilePath(url);
      print('📥 ImageCacheService: Downloading to: $filePath (filename: $fileName)');

      // Download the image with user agent to bypass some CORS issues
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
          'Accept': 'image/webp,image/apng,image/*,*/*;q=0.8',
          'Accept-Language': 'en-US,en;q=0.9',
          'Cache-Control': 'no-cache',
          'Referer': Uri.parse(url).origin,
        },
      );

      print('📊 ImageCacheService: Response status: ${response.statusCode}');
      print('📊 ImageCacheService: Response headers: ${response.headers}');
      print('📊 ImageCacheService: Content length: ${response.bodyBytes.length}');

      if (response.statusCode == 200) {
        if (filePath != null) {
          final file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);
          final fileStats = await file.stat();
          print('✅ ImageCacheService: Image cached successfully: $filePath');
          print('📊 ImageCacheService: File size: ${fileStats.size} bytes');
          return file;
        }
      } else {
        print('❌ ImageCacheService: Failed to download image: ${response.statusCode} - $url');
        print('📊 ImageCacheService: Response body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');
      }
    } catch (e, stackTrace) {
      print('💥 ImageCacheService: Error downloading image: $e - $url');
      print('📊 ImageCacheService: Stack trace: $stackTrace');
    }
    return null;
  }

  /// Clear all cached images
  static Future<void> clearCache() async {
    try {
      print('🧹 ImageCacheService: Starting cache cleanup...');
      
      if (_cacheDirectory == null) {
        print('⚠️ ImageCacheService: Cache directory not initialized, initializing...');
        await initialize();
      }

      if (_cacheDirectory != null && await _cacheDirectory!.exists()) {
        final files = await _cacheDirectory!.list().toList();
        int deletedCount = 0;
        
        print('📊 ImageCacheService: Found ${files.length} files to delete');
        
        for (final file in files) {
          if (file is File) {
            try {
              print('🗑️ ImageCacheService: Deleting ${file.path}');
              await file.delete();
              deletedCount++;
            } catch (e) {
              print('❌ ImageCacheService: Failed to delete cached file: ${file.path} - $e');
            }
          }
        }
        
        print('✅ ImageCacheService: Cleared $deletedCount cached images');
      } else {
        print('⚠️ ImageCacheService: Cache directory does not exist or is null');
      }
    } catch (e) {
      print('💥 ImageCacheService: Error clearing image cache: $e');
    }
  }

  /// Get cache size in bytes
  static Future<int> getCacheSize() async {
    try {
      if (_cacheDirectory == null) return 0;
      if (!await _cacheDirectory!.exists()) return 0;

      int totalSize = 0;
      final files = await _cacheDirectory!.list().toList();
      
      for (final file in files) {
        if (file is File) {
          try {
            final stat = await file.stat();
            totalSize += stat.size;
          } catch (e) {
            print('Failed to get file size: ${file.path} - $e');
          }
        }
      }
      
      return totalSize;
    } catch (e) {
      print('Error calculating cache size: $e');
      return 0;
    }
  }

  /// Get cache info for debugging
  static Future<Map<String, dynamic>> getCacheInfo() async {
    try {
      if (_cacheDirectory == null) return {'exists': false};

      final exists = await _cacheDirectory!.exists();
      if (!exists) return {'exists': false};

      final files = await _cacheDirectory!.list().toList();
      final size = await getCacheSize();

      return {
        'exists': true,
        'path': _cacheDirectory!.path,
        'fileCount': files.length,
        'sizeBytes': size,
        'sizeMB': (size / 1024 / 1024).toStringAsFixed(2),
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}
