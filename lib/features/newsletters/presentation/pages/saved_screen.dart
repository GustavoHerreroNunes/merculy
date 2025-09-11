import 'package:flutter/material.dart';
import '../../../../core/constants/color_palette.dart';
import '../../../../core/components/bottom_navigation_component.dart';
import '../../../../core/navigation/navigation_controller.dart';
import '../../../../core/components/newsletter_card.dart';
import '../../../../core/services/newsletter_service.dart';
import '../../domain/entities/newsletter.dart';
import 'newsletter_detail_page.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
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
      final newsletters = await NewsletterService.getNewsletters(saved: true);
      
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
      
      if (!newSavedStatus) {
        // If newsletter was unsaved, remove it from the list and refresh
        setState(() {
          _newsletters.removeAt(index);
        });
        
        // Show feedback
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Newsletter removida dos salvos'),
              backgroundColor: AppColors.primary,
              duration: Duration(seconds: 2),
            ),
          );
        }
        
        // Refresh the list to make sure we're in sync with the server
        await _loadNewsletters();
      } else {
        // Newsletter was saved (shouldn't happen on saved screen, but handle it)
        setState(() {
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
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao remover newsletter: $e'),
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Notícias Salvas',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [          
            // Content
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
      
      // Bottom Navigation
      bottomNavigationBar: BottomNavigationComponent(
        forcePage: BottomNavPage.saved
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
              Icons.bookmark_outline,
              size: 64,
              color: AppColors.textMedium,
            ),
            const SizedBox(height: 16),
            const Text(
              'Suas newsletter salvas aparecerão aqui',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Acesse \'newsletters\' e escolha uma para salvar',
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
