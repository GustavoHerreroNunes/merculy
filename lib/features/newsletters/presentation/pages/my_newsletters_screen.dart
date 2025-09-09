import 'package:flutter/material.dart';
import '../../../../core/constants/color_palette.dart';
import '../../../../core/components/bottom_navigation_component.dart';
import '../../../../core/navigation/navigation_controller.dart';
import '../../../../core/components/news_topic_card.dart';
import '../../../../core/services/newsletter_service.dart';
import '../../domain/entities/topic.dart';
import 'topic_newsletters_screen.dart';

class MyNewslettersScreen extends StatefulWidget {
  const MyNewslettersScreen({super.key});

  @override
  State<MyNewslettersScreen> createState() => _MyNewslettersScreenState();
}

class _MyNewslettersScreenState extends State<MyNewslettersScreen> {
  List<Topic> _userTopics = [];
  bool _isLoading = false;
  bool _isGenerating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserTopics();
  }

  Future<void> _loadUserTopics() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final topics = await NewsletterService.getUserTopics();
      setState(() {
        _userTopics = topics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _generateNewsletter() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      await NewsletterService.generateNewsletter();
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Newsletter gerada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
      
      // Refresh the topics (in case new ones were added)
      await _loadUserTopics();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao gerar newsletter: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final months = [
      '', 'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    final currentDate = '${now.day} de ${months[now.month]}';
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentDate,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Meus Tópicos',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textMedium,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Generate Newsletter Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isGenerating ? null : _generateNewsletter,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isGenerating
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Gerando Newsletter...'),
                          ],
                        )
                      : const Text(
                          'Gerar Nova Newsletter',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
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
      
      // Bottom Navigation
      bottomNavigationBar: BottomNavigationComponent(
        forcePage: BottomNavPage.newsletters
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Erro ao carregar tópicos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textMedium,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadUserTopics,
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    // Create list of topics including user topics + customized newsletters topic
    List<Widget> topicCards = [];
    
    // Add user topic cards
    for (var topic in _userTopics) {
      topicCards.add(
        NewsTopicCard(
          topic: topic.name,
          icon: topic.iconData,
          primaryColor: topic.primaryColor,
          secondaryColor: topic.secondaryColor,
          newsletterCount: 0, // TODO: Get actual count
          onTap: () => _navigateToTopic(topic),
        ),
      );
    }
    
    // Add customized newsletters topic (always present)
    topicCards.add(
      NewsTopicCard(
        topic: 'Personalizadas',
        icon: Icons.auto_awesome,
        primaryColor: AppColors.primary,
        secondaryColor: AppColors.primary.withOpacity(0.1),
        newsletterCount: 0, // TODO: Get actual count
        onTap: () => _navigateToCustomizedNewsletters(),
      ),
    );

    if (topicCards.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.topic_outlined,
              size: 64,
              color: AppColors.textMedium,
            ),
            const SizedBox(height: 16),
            const Text(
              'Nenhum tópico configurado',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Configure seus interesses para ver newsletters personalizadas!',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textMedium,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUserTopics,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        itemCount: topicCards.length,
        itemBuilder: (context, index) {
          return topicCards[index];
        },
      ),
    );
  }

  void _navigateToTopic(Topic topic) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TopicNewslettersScreen(
          topicId: topic.id,
          topicName: topic.name,
          topicIcon: topic.iconData,
          topicColor: topic.primaryColor,
        ),
      ),
    );
  }

  void _navigateToCustomizedNewsletters() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TopicNewslettersScreen(
          topicId: 'personalizada',
          topicName: 'Personalizadas',
          topicIcon: Icons.auto_awesome,
          topicColor: AppColors.primary,
        ),
      ),
    );
  }
}
