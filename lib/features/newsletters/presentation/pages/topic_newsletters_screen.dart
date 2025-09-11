import 'package:flutter/material.dart';
import '../../../../core/constants/color_palette.dart';
import '../../../../core/components/newsletter_card.dart';
import '../../../../core/services/newsletter_service.dart';
import '../../domain/entities/newsletter.dart';
import 'newsletter_detail_page.dart';

class TopicNewslettersScreen extends StatefulWidget {
  final String topicId;
  final String topicName;
  final IconData topicIcon;
  final Color topicColor;

  const TopicNewslettersScreen({
    super.key,
    required this.topicId,
    required this.topicName,
    required this.topicIcon,
    required this.topicColor,
  });

  @override
  State<TopicNewslettersScreen> createState() => _TopicNewslettersScreenState();
}

class _TopicNewslettersScreenState extends State<TopicNewslettersScreen> {
  List<Newsletter> _newsletters = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNewsletters();
  }

  Future<void> _loadNewsletters() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Get newsletters for this specific topic
      final newsletters = await NewsletterService.getNewslettersByTopic(widget.topicId);
      setState(() {
        _newsletters = newsletters;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleSaveNewsletter(Newsletter newsletter, int index) async {
    try {
      final newSavedStatus = await NewsletterService.toggleNewsletterSave(newsletter.id);
      
      setState(() {
        // Update the newsletter in the list with the new saved status
        _newsletters[index] = Newsletter(
          id: newsletter.id,
          title: newsletter.title,
          description: newsletter.description,
          icon: newsletter.icon,
          date: newsletter.date,
          hasNewData: newsletter.hasNewData,
          saved: newSavedStatus,
          headlines: newsletter.headlines,
          primaryColor: newsletter.primaryColor,
          secondaryColor: newsletter.secondaryColor,
          topic: newsletter.topic
        );
      });

      // Show feedback to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newSavedStatus ? 'Newsletter salva!' : 'Newsletter removida dos salvos'),
            backgroundColor: widget.topicColor,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar newsletter: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: widget.topicColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Icon(
              widget.topicIcon,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              widget.topicName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: widget.topicColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Newsletters de ${widget.topicName}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_newsletters.length} newsletters encontradas',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            
            // Content
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(widget.topicColor),
            ),
            const SizedBox(height: 16),
            Text(
              'Carregando newsletters...',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textMedium,
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Erro ao carregar newsletters',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textMedium,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadNewsletters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.topicColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (_newsletters.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.topicIcon,
                size: 64,
                color: widget.topicColor.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Nenhuma newsletter encontrada',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Ainda não há newsletters para ${widget.topicName}.',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textMedium,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.topicColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Voltar'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNewsletters,
      color: widget.topicColor,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        itemCount: _newsletters.length,
        itemBuilder: (context, index) {
          final newsletter = _newsletters[index];
          return NewsletterCard(
            newsletter: newsletter,
            isSaved: newsletter.saved,
            onTap: () => _navigateToNewsletter(newsletter),
            onSave: () => _toggleSaveNewsletter(newsletter, index),
          );
        },
      ),
    );
  }

  void _navigateToNewsletter(Newsletter newsletter) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NewsletterDetailPage(newsletter: newsletter),
      ),
    );
  }
}
