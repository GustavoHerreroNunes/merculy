import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/color_palette.dart';
import '../../domain/entities/news_headline.dart';
import '../../domain/entities/source.dart';

class ArticleDetailPage extends StatelessWidget {
  final NewsHeadline article;
  final String newsletterType;
  final Color primaryColor;
  final Color secondaryColor;
  final IconData newsletterIcon;

  const ArticleDetailPage({
    super.key,
    required this.article,
    required this.newsletterType,
    required this.primaryColor,
    required this.secondaryColor,
    required this.newsletterIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar with back button
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share, color: AppColors.textDark),
                onPressed: () {
                  // Handle share functionality
                },
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: AppColors.textDark),
                onPressed: () {
                  // Handle more options
                },
              ),
            ],
          ),
          
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tags
                  _buildTags(),
                  const SizedBox(height: 16),
                  
                  // Title
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                      height: 1.3,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Author and date
                  Text(
                    'By ${article.sources.isNotEmpty ? article.sources.first.fantasyName : "Merculy"} • ${_formatDate(article.publishedAt ?? DateTime.now())}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textMedium,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Cover Image
                  _buildCoverImage(),
                  
                  const SizedBox(height: 20),
                  
                  // Article Text
                  _buildArticleText(),
                  
                  const SizedBox(height: 30),
                  
                  // Conditionally show Bias Insights Chart (only for polarized news with valid data)
                  if (article.isPolarized == true && 
                      article.biasInsights != null && 
                      article.biasInsights!.isNotEmpty &&
                      article.biasInsights!.values.any((value) => value > 0)) ...[
                    _buildBiasInsights(),
                    const SizedBox(height: 30),
                  ],
                  
                  // Source Lists
                  _buildSourcesByBias(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTags() {
    return Row(
      children: [
        // Newsletter Type Tag with Icon
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: primaryColor),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                newsletterIcon,
                size: 14,
                color: primaryColor,
              ),
              const SizedBox(width: 4),
              Text(
                newsletterType.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Polarization Tag
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(
              color: article.isPolarized == true ? Colors.red : Colors.green,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                article.isPolarized == true ? Icons.flag : Icons.eco,
                size: 14,
                color: article.isPolarized == true ? Colors.red : Colors.green,
              ),
              const SizedBox(width: 4),
              Text(
                article.isPolarized == true ? 'POLARIZADA' : 'NÃO POLARIZADA',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: article.isPolarized == true ? Colors.red : Colors.green,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCoverImage() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[300],
        image: article.coverImage != null 
          ? DecorationImage(
              image: NetworkImage(article.coverImage!),
              fit: BoxFit.cover,
              onError: (error, stackTrace) {
                // Fallback to placeholder
              },
            )
          : null,
      ),
      child: article.coverImage == null 
        ? const Center(
            child: Icon(Icons.image, size: 50, color: Colors.grey),
          )
        : null,
    );
  }

  Widget _buildArticleText() {
    return Text(
      article.fullText ?? 'Conteúdo do artigo não disponível.',
      style: const TextStyle(
        fontSize: 16,
        color: AppColors.textDark,
        height: 1.6,
      ),
    );
  }

  Widget _buildBiasInsights() {
    final biasData = article.biasInsights;
    
    // Safety check - this method should only be called when data exists
    if (biasData == null || biasData.isEmpty) {
      return const SizedBox.shrink();
    }
    
    // Calculate colors based on newsletter colors
    final centerColor = primaryColor;
    final leftColor = HSLColor.fromColor(primaryColor)
        .withLightness((HSLColor.fromColor(primaryColor).lightness + 0.15).clamp(0.0, 1.0))
        .toColor();
    final rightColor = HSLColor.fromColor(primaryColor)
        .withLightness((HSLColor.fromColor(primaryColor).lightness - 0.2).clamp(0.0, 1.0))
        .toColor();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Insights sobre viés',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        
        const SizedBox(height: 52), // Increased from 20 to 32
        
        Row(
          children: [
            // Pie Chart
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 150,
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        color: centerColor,
                        value: biasData['Centro']!.toDouble(),
                        title: '',
                        radius: 60,
                      ),
                      PieChartSectionData(
                        color: leftColor,
                        value: biasData['Esquerda']!.toDouble(),
                        title: '',
                        radius: 60,
                      ),
                      PieChartSectionData(
                        color: rightColor,
                        value: biasData['Direita']!.toDouble(),
                        title: '',
                        radius: 60,
                      ),
                    ],
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 20),
            
            // Legend
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLegendItem(centerColor, 'Centro', biasData['Centro']!),
                  const SizedBox(height: 8),
                  _buildLegendItem(leftColor, 'Esquerda', biasData['Esquerda']!),
                  const SizedBox(height: 8),
                  _buildLegendItem(rightColor, 'Direita', biasData['Direita']!),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 44), // Increased from 16 to 24
        
        const Text(
          'Distribuição notícias pelo espectro político',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textMedium,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label, int count) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$label ($count)',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildSourcesByBias() {
    final sourcesByBias = article.sourcesByBias;
    
    // Handle case where no sources data is available
    if (sourcesByBias == null) {
      // Show fallback sources from the basic article sources if available
      if (article.sources.isNotEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fontes (${article.sources.length})',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),
            ...article.sources.map((source) => _buildSourceCard(source, primaryColor)),
          ],
        );
      } else {
        // No sources at all, don't show this section
        return const SizedBox.shrink();
      }
    }

    // Count total sources
    final allSources = sourcesByBias.values.expand((sources) => sources).toList();
    final totalSources = allSources.length;
    
    // If no sources in bias analysis but we have basic article sources, fall back
    if (totalSources == 0 && article.sources.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fontes (${article.sources.length})',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          ...article.sources.map((source) => _buildSourceCard(source, primaryColor)),
        ],
      );
    }
    
    // If no sources at all, hide the section
    if (totalSources == 0 && article.sources.isEmpty) {
      return const SizedBox.shrink();
    }

    if (article.isPolarized != true) {
      // Non-polarized news: show all sources together without subsection titles
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fontes ($totalSources)',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          ...allSources.map((source) => _buildSourceCard(source, primaryColor)),
        ],
      );
    }

    // Polarized news: show sections by political bias
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fontes ($totalSources)',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 20),
        
        _buildSourceSection('Matérias ao Centro', sourcesByBias['Centro']!, primaryColor),
        const SizedBox(height: 24),
        _buildSourceSection('Matérias à Esquerda', sourcesByBias['Esquerda']!, 
          HSLColor.fromColor(primaryColor)
              .withLightness((HSLColor.fromColor(primaryColor).lightness + 0.15).clamp(0.0, 1.0))
              .toColor()),
        const SizedBox(height: 24),
        _buildSourceSection('Matérias à Direita', sourcesByBias['Direita']!, 
          HSLColor.fromColor(primaryColor)
              .withLightness((HSLColor.fromColor(primaryColor).lightness - 0.2).clamp(0.0, 1.0))
              .toColor()),
      ],
    );
  }

  Widget _buildSourceSection(String title, List<Source> sources, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        
        const SizedBox(height: 12),
        
        if (sources.isNotEmpty)
          ...sources.map((source) => _buildSourceCard(source, accentColor))
        else
          _buildSourcePlaceholder(accentColor),
      ],
    );
  }

  Widget _buildSourcePlaceholder(Color accentColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accentColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Placeholder Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.remove_red_eye_outlined,
              color: accentColor,
              size: 20,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Placeholder Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Possível Blind Spot',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: accentColor.withOpacity(0.8),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: accentColor.withOpacity(0.3),
                        width: 4,
                      ),
                    ),
                  ),
                  child: Text(
                    'Não há fontes disponíveis para este espectro político no momento.',
                    style: TextStyle(
                      fontSize: 13,
                      color: accentColor.withOpacity(0.7),
                      fontStyle: FontStyle.italic,
                      height: 1.4,
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

  Widget _buildSourceCard(Source source, Color accentColor) {
    return GestureDetector(
      onTap: () => _launchURL(source.articleLink),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.05), // Light color background
          borderRadius: BorderRadius.circular(12), // Rounded container
          border: Border.all(
            color: accentColor.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Source Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: accentColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.language,
                color: Colors.white,
                size: 20,
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Source Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Source Name (prominent)
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          source.fantasyName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.open_in_new,
                        size: 16,
                        color: accentColor.withValues(alpha: 0.7),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Article Title
                  if (source.title != null && source.title!.isNotEmpty) ...[
                    Text(
                      source.title!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  
                  // Quote/Content
                  if (source.quote != null && source.quote!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: accentColor,
                            width: 4, // Bold left border
                          ),
                        ),
                      ),
                      child: Text(
                        source.quote!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textMedium,
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Launch URL in external browser
  Future<void> _launchURL(String url) async {
    if (url.isEmpty) {
      print('DEBUG: No URL provided for source');
      return;
    }
    
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication, // Opens in external browser
        );
      } else {
        print('DEBUG: Could not launch URL: $url');
      }
    } catch (e) {
      print('DEBUG: Error launching URL $url: $e');
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      '', 'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
      'jul', 'ago', 'set', 'out', 'nov', 'dez'
    ];
    return '${date.day.toString().padLeft(2, '0')}/${months[date.month]}/${date.year}';
  }
}
