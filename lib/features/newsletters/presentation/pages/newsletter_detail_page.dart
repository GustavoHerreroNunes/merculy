import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/color_palette.dart';
import '../../../../core/services/web_image_cache_service.dart';
import '../../../../core/components/web_smart_network_image.dart';
import '../../domain/entities/newsletter.dart';
import '../../domain/entities/news_headline.dart';
import 'article_detail_page.dart';

class NewsletterDetailPage extends StatefulWidget {
  final Newsletter newsletter;

  const NewsletterDetailPage({
    super.key,
    required this.newsletter,
  });

  @override
  State<NewsletterDetailPage> createState() => _NewsletterDetailPageState();
}

class _NewsletterDetailPageState extends State<NewsletterDetailPage> {
  @override
  void initState() {
    super.initState();
    print('📰 NewsletterDetailPage: Opening newsletter: ${widget.newsletter.title}');
    _cleanupImageCache();
    _debugNewsletterImages();
  }

  /// Debug newsletter images
  void _debugNewsletterImages() {
    print('🖼️ NewsletterDetailPage: Main news images:');
    for (int i = 0; i < widget.newsletter.mainNews.length; i++) {
      final headline = widget.newsletter.mainNews[i];
      print('   [$i] ${headline.title}: ${headline.coverImage ?? "NO IMAGE"}');
    }
    
    print('🖼️ NewsletterDetailPage: Other news images:');
    for (int i = 0; i < widget.newsletter.otherNews.length; i++) {
      final headline = widget.newsletter.otherNews[i];
      print('   [$i] ${headline.title}: ${headline.coverImage ?? "NO IMAGE"}');
    }
  }

  /// Cleanup image cache when opening newsletter detail
  Future<void> _cleanupImageCache() async {
    try {
      print('🧹 NewsletterDetailPage: Cleaning up image cache...');
      if (kIsWeb) {
        await WebImageCacheService.clearCache();
      } else {
        // For mobile/desktop
        print('Mobile cache cleanup not implemented yet');
      }
      print('✅ NewsletterDetailPage: Image cache cleared successfully');
    } catch (e) {
      print('💥 NewsletterDetailPage: Failed to clear image cache: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Custom Header with Custom Painter
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: widget.newsletter.primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              background: CustomPaint(
                painter: NewsletterHeaderPainter(
                  primaryColor: widget.newsletter.primaryColor,
                  secondaryColor: widget.newsletter.secondaryColor,
                ),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              widget.newsletter.icon,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.newsletter.title,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatDate(widget.newsletter.date),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () => _shareNewsletter(),
              ),
            ],
          ),
          
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [                 
                  // Main News Section
                  if (widget.newsletter.mainNews.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildMainNewsSection(context),
                    const SizedBox(height: 32),
                  ],
                  
                  // Other News Section
                  if (widget.newsletter.otherNews.isNotEmpty) ...[
                                        _buildOtherNewsSection(context),
                    const SizedBox(height: 32),
                  ],
                  
                  // Share Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _shareNewsletter,
                      icon: const Icon(Icons.share),
                      label: const Text('Compartilhar Newsletter'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: widget.newsletter.primaryColor,
                        side: BorderSide(color: widget.newsletter.primaryColor),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainNewsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Principais Notícias',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 16),
        ...widget.newsletter.mainNews.map((headline) => _buildMainNewsCard(context, headline)),
      ],
    );
  }

  Widget _buildMainNewsCard(BuildContext context, NewsHeadline headline) {
    print('DEBUG UI: Building main news card for: ${headline.title}');
    print('DEBUG UI: Cover image URL: ${headline.coverImage}');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover Image - Always show for main news
          _buildCoverImage(headline),
          
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // News title - Always show
                Text(
                  headline.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    height: 1.3,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Summary - Always show for main news (provide default if null)
                Text(
                  headline.summary ?? 'Leia mais para descobrir os detalhes desta notícia importante.',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textMedium,
                    height: 1.5,
                  ),
                ),
                
                // Important topics - Always show section for main news
                const SizedBox(height: 16),
                const Text(
                  'Tópicos importantes:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Show topics as bullet point list or default message
                if (headline.mainTopics != null && headline.mainTopics!.isNotEmpty) 
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: headline.mainTopics!.map((topic) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.only(top: 6, right: 12),
                              decoration: BoxDecoration(
                                color: widget.newsletter.primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                topic,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textDark,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.only(top: 6, right: 12),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const Expanded(
                          child: Text(
                            'Assunto de interesse geral com informações relevantes',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.orange,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                const SizedBox(height: 16),
                Center(
                  child: GestureDetector(
                    onTap: () => _openArticle(context, headline),
                    child: Text(
                      'Detalhes',
                      style: TextStyle(
                        color: widget.newsletter.primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                        decorationColor: widget.newsletter.primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverImage(NewsHeadline headline) {
    print('🖼️ NewsletterDetailPage: Building cover image for: "${headline.title}"');
    print('🖼️ NewsletterDetailPage: Image URL: ${headline.coverImage ?? "NULL"}');
    
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.newsletter.primaryColor.withValues(alpha: 0.1),
            widget.newsletter.secondaryColor.withValues(alpha: 0.3),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Try to load network image with fallback
          if (headline.coverImage != null && headline.coverImage!.isNotEmpty) ...[
            () {
              print('✅ NewsletterDetailPage: Creating WebSmartNetworkImage for ${headline.coverImage}');
              return WebSmartNetworkImage(
                imageUrl: headline.coverImage!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                placeholder: _buildImagePlaceholder('Carregando imagem...'),
                errorWidget: _buildImagePlaceholder('Imagem não disponível'),
              );
            }(),
          ] else ...[
            () {
              print('⚠️ NewsletterDetailPage: No image URL, showing placeholder');
              return _buildImagePlaceholder('Sem imagem');
            }(),
          ],
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder(String message) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.newsletter.primaryColor.withValues(alpha: 0.2),
            widget.newsletter.primaryColor.withValues(alpha: 0.1),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.newspaper,
            size: 48,
            color: widget.newsletter.primaryColor.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              color: widget.newsletter.primaryColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: widget.newsletter.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Notícia Merculy',
              style: TextStyle(
                color: widget.newsletter.primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtherNewsSection(BuildContext context) {
    return Container(
      width: double.infinity, // 100% width
      color: Colors.white, // No border radius
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with magnifier icon and background
          Container(
            width: double.infinity, // Full width
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: widget.newsletter.primaryColor, // No border radius
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.search,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Outras Notícias',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...widget.newsletter.otherNews.map((headline) => _buildOtherNewsCard(context, headline)),
        ],
      ),
    );
  }

  Widget _buildOtherNewsCard(BuildContext context, NewsHeadline headline) {
    // Get the first source for display
    final source = headline.sources.isNotEmpty ? headline.sources.first : null;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _openArticle(context, headline),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Source address
            if (source != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.newsletter.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  source.fantasyName,
                  style: TextStyle(
                    fontSize: 12,
                    color: widget.newsletter.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            
            // News title
            Text(
              headline.title,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textDark,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
            
            // Summary (if available)
            if (headline.summary != null) ...[
              const SizedBox(height: 8),
              Text(
                headline.summary!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textMedium,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      '', 'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    return '${date.day} de ${months[date.month]}';
  }

  void _shareNewsletter() {
    // Implement share functionality
  }

  void _openArticle(BuildContext context, NewsHeadline headline) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ArticleDetailPage(
          article: headline,
          newsletterType: widget.newsletter.title,
          primaryColor: widget.newsletter.primaryColor,
          secondaryColor: widget.newsletter.secondaryColor,
          newsletterIcon: widget.newsletter.icon,
        ),
      ),
    );
  }
}

class NewsletterHeaderPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;

  NewsletterHeaderPainter({
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Define the three color variations based on the primary color
    final Color baseColor = primaryColor;
    final Color darkerColor = HSLColor.fromColor(baseColor)
        .withLightness((HSLColor.fromColor(baseColor).lightness - 0.2).clamp(0.0, 1.0))
        .toColor();
    final Color lighterColor = HSLColor.fromColor(baseColor)
        .withLightness((HSLColor.fromColor(baseColor).lightness + 0.15).clamp(0.0, 1.0))
        .toColor();

    // Calculate dimensions
    final double primaryWidth = size.width * 0.65; // 65% of the width for primary color
    final double darkerBorderWidth = 20; // Bold border width
    final double pillRadius = size.height / 2; // Radius for perfect pill shape
    
    // 1. Primary color section (left side with pill-shaped right border)
    final Path primaryPath = Path();
    primaryPath.moveTo(0, 0);
    primaryPath.lineTo(primaryWidth - pillRadius, 0);
    primaryPath.arcToPoint(
      Offset(primaryWidth - pillRadius, size.height),
      radius: Radius.circular(pillRadius),
      clockwise: false,
    );
    primaryPath.lineTo(0, size.height);
    primaryPath.close();

    final Paint primaryPaint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.fill;

    canvas.drawPath(primaryPath, primaryPaint);

    // 2. Darker border section (middle - 20px bold border)
    final Rect darkerRect = Rect.fromLTWH(
      primaryWidth - 30, 
      0, 
      darkerBorderWidth + 30, 
      size.height
    );

    final Paint darkerPaint = Paint()
      ..color = darkerColor
      ..style = PaintingStyle.fill;

    canvas.drawRect(darkerRect, darkerPaint);

    // 3. Lighter color section (right side - remaining space)
    final Rect lighterRect = Rect.fromLTWH(
      primaryWidth + darkerBorderWidth - 30, 
      0, 
      size.width - (primaryWidth + darkerBorderWidth - 30), 
      size.height
    );

    final Paint lighterPaint = Paint()
      ..color = lighterColor
      ..style = PaintingStyle.fill;

    canvas.drawRect(lighterRect, lighterPaint);

    // Add subtle gradient overlay for depth and visual interest
    final Rect gradientRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final Paint gradientOverlay = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withOpacity(0.1),
          Colors.transparent,
          Colors.black.withOpacity(0.05),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(gradientRect);

    canvas.drawRect(gradientRect, gradientOverlay);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
