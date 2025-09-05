import 'dart:io';
import 'package:flutter/material.dart';
import '../services/image_cache_service.dart';

class SmartNetworkImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  const SmartNetworkImage({
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
  State<SmartNetworkImage> createState() => _SmartNetworkImageState();
}

class _SmartNetworkImageState extends State<SmartNetworkImage> {
  bool _isLoading = true;
  bool _hasError = false;
  File? _cachedImageFile;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    if (!mounted) return;

    print('🖼️ SmartNetworkImage: Starting to load image: ${widget.imageUrl}');

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // First, check if image is already cached
      print('🔍 SmartNetworkImage: Checking if image is cached...');
      final cachedFile = await ImageCacheService.getCachedImageFile(widget.imageUrl);
      
      if (cachedFile != null && await cachedFile.exists()) {
        print('✅ SmartNetworkImage: Found cached image at: ${cachedFile.path}');
        if (mounted) {
          setState(() {
            _cachedImageFile = cachedFile;
            _isLoading = false;
            _hasError = false;
          });
        }
        return;
      }

      print('📥 SmartNetworkImage: Image not cached, attempting to download...');
      // Try to download and cache the image
      final downloadedFile = await ImageCacheService.downloadAndCacheImage(widget.imageUrl);
      
      if (downloadedFile != null && await downloadedFile.exists()) {
        print('✅ SmartNetworkImage: Successfully downloaded and cached image at: ${downloadedFile.path}');
        if (mounted) {
          setState(() {
            _cachedImageFile = downloadedFile;
            _isLoading = false;
            _hasError = false;
          });
        }
      } else {
        // Download failed, show error
        print('❌ SmartNetworkImage: Download failed for: ${widget.imageUrl}');
        if (mounted) {
          setState(() {
            _isLoading = false;
            _hasError = true;
          });
        }
      }
    } catch (e) {
      print('💥 SmartNetworkImage: Error loading image ${widget.imageUrl}: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  Widget _buildNetworkImage() {
    print('🌐 SmartNetworkImage: Attempting direct network load for: ${widget.imageUrl}');
    return Image.network(
      widget.imageUrl,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          print('✅ SmartNetworkImage: Network image loaded successfully');
          return child;
        }
        
        final progress = loadingProgress.expectedTotalBytes != null
            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
            : null;
        print('📊 SmartNetworkImage: Loading progress: ${progress != null ? (progress * 100).toStringAsFixed(1) : "unknown"}%');
        
        // If network loading fails, try to load from cache
        return widget.placeholder ?? _buildDefaultPlaceholder();
      },
      errorBuilder: (context, error, stackTrace) {
        print('❌ SmartNetworkImage: Network image failed: $error');
        print('📱 SmartNetworkImage: URL: ${widget.imageUrl}');
        print('🔄 SmartNetworkImage: Attempting to load from cache...');
        
        // Network image failed, trigger cache download
        Future.microtask(() => _loadImage());
        
        return widget.placeholder ?? _buildDefaultPlaceholder();
      },
    );
  }

  Widget _buildCachedImage() {
    if (_cachedImageFile == null) {
      print('❌ SmartNetworkImage: No cached image file available');
      return _buildErrorWidget();
    }
    
    print('📁 SmartNetworkImage: Loading from cached file: ${_cachedImageFile!.path}');
    
    return Image.file(
      _cachedImageFile!,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      errorBuilder: (context, error, stackTrace) {
        print('❌ SmartNetworkImage: Cached image failed to load: $error');
        print('📁 SmartNetworkImage: File path: ${_cachedImageFile!.path}');
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
                  color: Colors.white.withOpacity(0.8),
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

    print('🏗️ SmartNetworkImage: Building widget for ${widget.imageUrl}');
    print('   - isLoading: $_isLoading');
    print('   - hasError: $_hasError');
    print('   - cachedFile: ${_cachedImageFile?.path ?? "null"}');

    if (_isLoading) {
      print('🔄 SmartNetworkImage: Showing loading placeholder');
      imageWidget = widget.placeholder ?? _buildDefaultPlaceholder();
    } else if (_hasError) {
      print('💥 SmartNetworkImage: Showing error widget');
      imageWidget = _buildErrorWidget();
    } else if (_cachedImageFile != null) {
      print('📁 SmartNetworkImage: Showing cached image');
      imageWidget = _buildCachedImage();
    } else {
      print('🌐 SmartNetworkImage: Fallback - trying direct network image');
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
