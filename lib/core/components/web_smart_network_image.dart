import 'dart:html' as html;
import 'package:flutter/material.dart';
import '../services/web_image_cache_service.dart';

class WebSmartNetworkImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  const WebSmartNetworkImage({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
  }) : super(key: key);

  @override
  State<WebSmartNetworkImage> createState() => _WebSmartNetworkImageState();
}

class _WebSmartNetworkImageState extends State<WebSmartNetworkImage> {
  bool _isLoading = true;
  bool _hasError = false;
  String? _cachedDataUrl;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    if (!mounted) return;

    print('🖼️ WebSmartNetworkImage: Starting to load image: ${widget.imageUrl}');

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // First, check if image is already cached
      print('🔍 WebSmartNetworkImage: Checking if image is cached...');
      final cachedData = await WebImageCacheService.getCachedImageData(widget.imageUrl);
      
      if (cachedData != null && cachedData.isNotEmpty) {
        print('✅ WebSmartNetworkImage: Found cached image data');
        if (mounted) {
          setState(() {
            _cachedDataUrl = cachedData;
            _isLoading = false;
            _hasError = false;
          });
        }
        return;
      }

      print('📥 WebSmartNetworkImage: Image not cached, attempting to download...');
      // Try to download and cache the image
      final downloadedData = await WebImageCacheService.downloadAndCacheImage(widget.imageUrl);
      
      if (downloadedData != null && downloadedData.isNotEmpty) {
        print('✅ WebSmartNetworkImage: Successfully downloaded and cached image');
        if (mounted) {
          setState(() {
            _cachedDataUrl = downloadedData;
            _isLoading = false;
            _hasError = false;
          });
        }
      } else {
        // Download failed, try direct network load as fallback
        print('⚠️ WebSmartNetworkImage: Download failed, falling back to direct network load');
        if (mounted) {
          setState(() {
            _isLoading = false;
            _hasError = false; // Let the network image try
          });
        }
      }
    } catch (e) {
      print('💥 WebSmartNetworkImage: Error loading image ${widget.imageUrl}: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = false; // Let the network image try as fallback
        });
      }
    }
  }

  Widget _buildNetworkImage() {
    print('🌐 WebSmartNetworkImage: Attempting direct network load for: ${widget.imageUrl}');
    return Image.network(
      widget.imageUrl,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          print('✅ WebSmartNetworkImage: Network image loaded successfully');
          return child;
        }
        
        final progress = loadingProgress.expectedTotalBytes != null
            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
            : null;
        print('📊 WebSmartNetworkImage: Loading progress: ${progress != null ? (progress * 100).toStringAsFixed(1) : "unknown"}%');
        
        return widget.placeholder ?? _buildDefaultPlaceholder();
      },
      errorBuilder: (context, error, stackTrace) {
        print('❌ WebSmartNetworkImage: Network image failed: $error');
        print('📱 WebSmartNetworkImage: URL: ${widget.imageUrl}');
        
        return widget.errorWidget ?? _buildErrorWidget();
      },
    );
  }

  Widget _buildCachedImage() {
    if (_cachedDataUrl == null) {
      print('❌ WebSmartNetworkImage: No cached data URL available');
      return _buildErrorWidget();
    }
    
    print('📁 WebSmartNetworkImage: Loading from cached data URL');
    
    return Image.network(
      _cachedDataUrl!,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      errorBuilder: (context, error, stackTrace) {
        print('❌ WebSmartNetworkImage: Cached data URL failed to load: $error');
        return _buildErrorWidget();
      },
    );
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: widget.borderRadius,
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return widget.errorWidget ??
        Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: widget.borderRadius,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.article_outlined,
                size: 48,
                color: Colors.white70,
              ),
              const SizedBox(height: 8),
              const Text(
                'Merculy',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Newsletter',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    print('🏗️ WebSmartNetworkImage: Building widget for ${widget.imageUrl}');
    print('   - isLoading: $_isLoading');
    print('   - hasError: $_hasError');
    print('   - cachedDataUrl: ${_cachedDataUrl != null ? "available" : "null"}');

    if (_isLoading) {
      print('🔄 WebSmartNetworkImage: Showing loading placeholder');
      imageWidget = widget.placeholder ?? _buildDefaultPlaceholder();
    } else if (_hasError) {
      print('💥 WebSmartNetworkImage: Showing error widget');
      imageWidget = _buildErrorWidget();
    } else if (_cachedDataUrl != null) {
      print('📁 WebSmartNetworkImage: Showing cached image');
      imageWidget = _buildCachedImage();
    } else {
      print('🌐 WebSmartNetworkImage: Fallback - trying direct network image');
      imageWidget = _buildNetworkImage();
    }

    if (widget.borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: widget.borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}
