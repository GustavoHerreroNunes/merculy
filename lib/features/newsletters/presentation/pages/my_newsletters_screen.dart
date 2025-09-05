import 'package:flutter/material.dart';
import '../../../../core/constants/color_palette.dart';
import '../../../../core/components/bottom_navigation_component.dart';
import '../../../../core/navigation/navigation_controller.dart';
import '../../../../core/components/newsletter_card.dart';
import '../../../../core/services/newsletter_service.dart';
import '../../../settings/presentation/pages/configuration_page.dart';
import '../../domain/entities/newsletter.dart';
import 'newsletter_detail_page.dart';
import 'channels_screen.dart';

class MyNewslettersScreen extends StatefulWidget {
  const MyNewslettersScreen({super.key});

  @override
  State<MyNewslettersScreen> createState() => _MyNewslettersScreenState();
}

class _MyNewslettersScreenState extends State<MyNewslettersScreen> {
  List<Newsletter> _newsletters = [];
  bool _isLoading = false;
  bool _isGenerating = false;
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
      final newsletters = await NewsletterService.getNewsletters();
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
      
      // Refresh the newsletters
      await _loadNewsletters();
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
                    'Minhas Newsletters',
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
        forcePage: BottomNavPage.newsletters,
        onPageChanged: (page) {
          _handleNavigation(page);
        },
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
            Text(
              'Erro ao carregar newsletters',
              style: const TextStyle(
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
              onPressed: _loadNewsletters,
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    if (_newsletters.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.article_outlined,
              size: 64,
              color: AppColors.textMedium,
            ),
            const SizedBox(height: 16),
            const Text(
              'Nenhuma newsletter encontrada',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Gere sua primeira newsletter personalizada!',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textMedium,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNewsletters,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        itemCount: _newsletters.length,
        itemBuilder: (context, index) {
          final newsletter = _newsletters[index];
          return NewsletterCard(
            newsletter: newsletter,
            onTap: () => _navigateToNewsletter(newsletter),
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

  void _handleNavigation(BottomNavPage page) {
    switch (page) {
      case BottomNavPage.newsletters:
        // Already on newsletters page, do nothing
        break;
      case BottomNavPage.saved:
        // TODO: Navigate to saved articles page
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Página de salvos em desenvolvimento')),
        );
        break;
      case BottomNavPage.channels:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const ChannelsScreen(),
            settings: const RouteSettings(name: '/channels'),
          ),
        );
        break;
      case BottomNavPage.settings:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const ConfigurationPage(),
            settings: const RouteSettings(name: '/configuration'),
          ),
        );
        break;
    }
  }
}
