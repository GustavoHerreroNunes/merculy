import 'package:flutter/material.dart';
import '../../../../core/constants/color_palette.dart';
import '../../../../core/components/bottom_navigation_component.dart';
import '../../../../core/components/newsletter_card.dart';
import '../../domain/entities/newsletter.dart';
import '../../domain/entities/news_headline.dart';
import '../../domain/entities/source.dart';
import 'newsletter_detail_page.dart';

class MyNewslettersScreen extends StatefulWidget {
  const MyNewslettersScreen({super.key});

  @override
  State<MyNewslettersScreen> createState() => _MyNewslettersScreenState();
}

class _MyNewslettersScreenState extends State<MyNewslettersScreen> {
  BottomNavPage _currentPage = BottomNavPage.newsletters;

  // Mock data - replace with actual data source
  List<Newsletter> get _newsletters {
    return [
      Newsletter(
        id: '1',
        title: 'Tech e Inovação',
        description: 'Sua dose semanal de inovação',
        icon: Icons.computer,
        date: DateTime.now(),
        hasNewData: true,
        primaryColor: Colors.blue,
        secondaryColor: Colors.blue.shade100,
        headlines: _generateMockHeadlines(),
      ),
      Newsletter(
        id: '2',
        title: 'Economia',
        description: 'Insights sobre o mercado em 2025',
        icon: Icons.attach_money,
        date: DateTime.now().subtract(const Duration(days: 1)),
        hasNewData: true,
        primaryColor: Colors.green,
        secondaryColor: Colors.green.shade100,
        headlines: _generateMockHeadlines(),
      ),
      Newsletter(
        id: '3',
        title: 'Política e País',
        description: 'Tudo sobre o cenário político do Brasil',
        icon: Icons.account_balance,
        date: DateTime.now().subtract(const Duration(days: 2)),
        hasNewData: true,
        primaryColor: Colors.purple,
        secondaryColor: Colors.purple.shade100,
        headlines: _generateMockHeadlines(),
      ),
      Newsletter(
        id: '4',
        title: 'Sustentabilidade',
        description: 'Ideias para um futuro melhor',
        icon: Icons.eco,
        date: DateTime.now().subtract(const Duration(days: 3)),
        hasNewData: false,
        primaryColor: Colors.orange,
        secondaryColor: Colors.orange.shade100,
        headlines: _generateMockHeadlines(),
      ),
    ];
  }

  List<NewsHeadline> _generateMockHeadlines() {
    return [
      NewsHeadline(
        title: 'Brasil Lança Programa Nacional de Hidrogênio Verde',
        summary: 'O governo federal anunciou um plano para tornar o Brasil líder na transição energética verde, com foco no hidrogênio renovável.',
        coverImage: 'assets/images/news1.jpg',
        mainTopics: ['Energia Renovável', 'Política Ambiental', 'Economia Verde'],
        isMainNews: true,
        sources: [
          Source(websiteRoot: 'g1.com.br', fantasyName: 'G1', articleLink: 'https://g1.com.br/sample'),
        ],
        publishedAt: DateTime.now(),
      ),
      NewsHeadline(
        title: 'Apple Planeja Nova Chip M1 3a Mais Rápida para a Geração Anterior',
        summary: 'Após rumor sobre o M3, crescimento desenfreado do chip está sendo aplicado para MacBooks e desktops.',
        isMainNews: true,
        sources: [
          Source(websiteRoot: 'apple.com', fantasyName: 'Apple', articleLink: 'https://apple.com/sample'),
        ],
        publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      NewsHeadline(
        title: 'Estudo do MIT questiona credibilidade da LLIMAma',
        isMainNews: true,
        sources: [
          Source(websiteRoot: 'mit.edu', fantasyName: 'MIT', articleLink: 'https://mit.edu/sample'),
        ],
        publishedAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      NewsHeadline(
        title: 'Novo Chip da IBM Quebra Recorde de Velocidade em Computação Quântica',
        isMainNews: false,
        sources: [
          Source(websiteRoot: 'ibm.com', fantasyName: 'IBM', articleLink: 'https://ibm.com/sample'),
        ],
        publishedAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
    ];
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
            
            // Newsletter cards
            Expanded(
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
            ),
          ],
        ),
      ),
      
      // Bottom Navigation
      bottomNavigationBar: BottomNavigationComponent(
        currentPage: _currentPage,
        onPageChanged: (page) {
          setState(() {
            _currentPage = page;
          });
          // Handle navigation to other pages here
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
