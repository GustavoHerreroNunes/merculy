import 'package:flutter/material.dart';
import '../../../../core/constants/color_palette.dart';
import '../../../../core/components/bottom_navigation_component.dart';
import '../../../../core/components/newsletter_card.dart';
import '../../../settings/presentation/pages/configuration_page.dart';
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
      // Main News (3 items)
      NewsHeadline(
        title: 'Brasil Lança Programa Nacional de Hidrogênio Verde',
        summary: 'O governo federal anunciou um plano para tornar o Brasil líder na transição energética verde, com foco no hidrogênio renovável.',
        coverImage: 'assets/images/news1.jpg',
        fullText: '''O governo federal anunciou nesta segunda-feira (5) o Programa Nacional de Hidrogênio Verde (PNHV), um ambicioso plano para posicionar o país como líder na produção e exportação deste combustível limpo.

Com um investimento inicial de R\$ 20 bilhões – divididos entre verbas públicas e parcerias privadas –, a iniciativa prevê a construção de 10 polos industriais em regiões com alto potencial eólico e solar, como o Nordeste e Sul.

"O programa equilibra inovação e pragmatismo, alinhando-se às demandas globais sem descuidar da competitividade industrial", declarou o ministro de Minas e Energia durante coletiva de imprensa.

A expectativa é que o Brasil se torne um dos principais exportadores de hidrogênio verde até 2030, aproveitando sua matriz energética renovável e posição geográfica estratégica para atender mercados europeus e asiáticos.''',
        mainTopics: [
          'O Brasil pretende se tornar uma potência mundial em energia renovável',
          'Investimentos de R\$ 200 bilhões serão destinados ao programa até 2030',
          'Mais de 500 mil empregos verdes serão criados nos próximos 5 anos'
        ],
        isMainNews: true,
        isPolarized: true,
        biasInsights: {'Centro': 1, 'Esquerda': 3, 'Direita': 3},
        sources: [
          Source(websiteRoot: 'g1.com.br', fantasyName: 'G1', articleLink: 'https://g1.com.br/sample'),
        ],
        sourcesByBias: {
          'Centro': [
            Source(
              websiteRoot: 'ncc.com.br', 
              fantasyName: 'NCC',
              articleLink: 'https://ncc.com.br/sample',
              title: 'Brasil dá passo histórico rumo à economia verde...',
              quote: '"O programa equilibra inovação e pragmatismo, alinhando-se às demandas globais sem descuidar da competitividade industrial..."'
            ),
          ],
          'Esquerda': [
            Source(
              websiteRoot: 'novo.com.br', 
              fantasyName: 'Novo',
              articleLink: 'https://novo.com.br/sample',
              title: 'Novo programa brasileiro pode democratizar energia',
              quote: '"Alguns especialistas criticam os editais e favorecem megacorporações. É preciso incluir cooperativas de energia e garantir que comunidades locais tenham acesso..."'
            ),
          ],
          'Direita': [], // Empty to demonstrate placeholder
        },
        publishedAt: DateTime.now(),
      ),
      NewsHeadline(
        title: 'Apple Anuncia Nova Geração do Chip M4 com Performance 3x Mais Rápida',
        summary: 'A gigante da tecnologia revelou seu mais novo processador que promete revolucionar a linha MacBook e iMac com eficiência energética sem precedentes.',
        coverImage: 'assets/images/news2.jpg',
        fullText: '''A Apple revelou oficialmente seu mais novo processador M4, prometendo uma revolução na computação pessoal com performance 300% superior à geração anterior e eficiência energética sem precedentes.

O novo chip, fabricado em processo de 3 nanômetros de segunda geração, integra 40 bilhões de transistores em uma arquitetura completamente redesenhada. A CPU de 12 núcleos (8 de performance e 4 de eficiência) trabalha em conjunto com uma GPU de 16 núcleos e um Neural Engine capaz de processar 38 trilhões de operações por segundo.

"Este é o maior salto tecnológico da Apple desde a transição para os chips próprios", declarou Tim Cook durante o evento de lançamento. "O M4 não apenas redefine o que esperamos de um computador pessoal, mas também estabelece as bases para a próxima década de inovação."

A nova arquitetura permite que aplicações de inteligência artificial rodem nativamente no dispositivo, eliminando a dependência de serviços em nuvem para muitas tarefas de IA. Isso representa um avanço significativo em privacidade e velocidade de processamento.

Os primeiros dispositivos equipados com o M4 chegam ao mercado em março de 2025, com a nova linha MacBook Pro e iMac prometendo autonomia de bateria de até 22 horas de uso contínuo.''',
        mainTopics: [
          'O novo chip M4 oferece 300% mais performance que a geração anterior',
          'Consumo energético reduzido em 40% comparado aos processadores Intel',
          'Integração com inteligência artificial nativa para todas as aplicações'
        ],
        isMainNews: true,
        isPolarized: false,
        biasInsights: {'Centro': 2, 'Esquerda': 1, 'Direita': 2},
        sources: [
          Source(websiteRoot: 'apple.com', fantasyName: 'Apple', articleLink: 'https://apple.com/sample'),
        ],
        sourcesByBias: {
          'Centro': [
            Source(
              websiteRoot: 'techcrunch.com', 
              fantasyName: 'TechCrunch',
              articleLink: 'https://techcrunch.com/sample',
              title: 'Apple M4: A revolução silenciosa dos processadores',
              quote: '"Este é o maior salto tecnológico da Apple desde a transição para os chips próprios, estabelecendo as bases para a próxima década de inovação."'
            ),
          ],
          'Esquerda': [
            Source(
              websiteRoot: 'wired.com', 
              fantasyName: 'Wired',
              articleLink: 'https://wired.com/sample',
              title: 'M4 da Apple: Inovação ou exclusão digital?',
              quote: '"Enquanto a Apple celebra avanços tecnológicos, questiona-se se esses desenvolvimentos ampliam ou reduzem o acesso à tecnologia de ponta."'
            ),
          ],
          'Direita': [
            Source(
              websiteRoot: 'forbes.com', 
              fantasyName: 'Forbes',
              articleLink: 'https://forbes.com/sample',
              title: 'Apple M4 reafirma liderança tecnológica americana',
              quote: '"A Apple demonstra mais uma vez por que os Estados Unidos lideram a inovação global em semicondutores e computação pessoal."'
            ),
          ],
        },
        publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      NewsHeadline(
        title: 'Estudo do MIT Revela Avanços Revolucionários em Computação Quântica',
        summary: 'Pesquisadores conseguiram manter qubits estáveis por mais de 1 hora, um recorde que pode acelerar o desenvolvimento de computadores quânticos comerciais.',
        coverImage: 'assets/images/news3.jpg',
        fullText: '''Pesquisadores do Instituto de Tecnologia de Massachusetts (MIT) alcançaram um marco histórico na computação quântica ao conseguir manter qubits em estado coerente por mais de uma hora, um aumento de mais de 10.000 vezes em relação aos recordes anteriores.

O breakthrough foi conseguido através de uma nova técnica de correção de erros quânticos que utiliza campos magnéticos ultraprecisos e controle de temperatura em escala nanométrica. A estabilidade estendida dos qubits é crucial para realizar cálculos complexos que podem revolucionar áreas como descoberta de medicamentos, criptografia e modelagem climática.

"Conseguimos criar um ambiente onde os qubits mantêm suas propriedades quânticas por tempo suficiente para executar algoritmos verdadeiramente úteis", explicou a Dra. Sarah Chen, líder da pesquisa. "Isto nos aproxima significativamente de computadores quânticos comercialmente viáveis."

O estudo, publicado na revista Nature, demonstra que a computação quântica está transitando de conceito teórico para aplicação prática. Empresas como IBM, Google e startups especializadas já manifestaram interesse em licenciar a tecnologia desenvolvida pelo MIT.

Os pesquisadores estimam que computadores quânticos baseados nesta tecnologia poderão ser utilizados para acelerar o desenvolvimento de novos medicamentos em até 90%, além de tornar obsoletos os atuais sistemas de criptografia em menos de uma década.''',
        mainTopics: [
          'Tempo de coerência quântica aumentou de segundos para mais de uma hora',
          'Descoberta pode acelerar o desenvolvimento de medicamentos em 90%',
          'Criptografia atual pode se tornar obsoleta nos próximos 10 anos'
        ],
        isMainNews: true,
        isPolarized: true,
        biasInsights: {'Centro': 3, 'Esquerda': 2, 'Direita': 1},
        sources: [
          Source(websiteRoot: 'mit.edu', fantasyName: 'MIT', articleLink: 'https://mit.edu/sample'),
        ],
        sourcesByBias: {
          'Centro': [
            Source(
              websiteRoot: 'nature.com', 
              fantasyName: 'Nature',
              articleLink: 'https://nature.com/sample',
              title: 'Quantum coherence breakthrough opens new possibilities',
              quote: '"Conseguimos criar um ambiente onde os qubits mantêm suas propriedades quânticas por tempo suficiente para executar algoritmos verdadeiramente úteis."'
            ),
          ],
          'Esquerda': [
            Source(
              websiteRoot: 'theguardian.com', 
              fantasyName: 'The Guardian',
              articleLink: 'https://theguardian.com/sample',
              title: 'Quantum computing: Promise or threat to privacy?',
              quote: '"Enquanto a tecnologia promete avanços médicos, levanta sérias questões sobre segurança digital e privacidade dos cidadãos."'
            ),
          ],
          'Direita': [
            Source(
              websiteRoot: 'wsj.com', 
              fantasyName: 'Wall Street Journal',
              articleLink: 'https://wsj.com/sample',
              title: 'MIT quantum breakthrough boosts US tech supremacy',
              quote: '"Este avanço reafirma a liderança americana em tecnologias emergentes e pode garantir vantagem estratégica por décadas."'
            ),
          ],
        },
        publishedAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      
      // Other News (4 items)
      NewsHeadline(
        title: 'IBM Anuncia Parceria com Universidades Brasileiras para Pesquisa em IA',
        summary: 'A empresa investirá R\$ 50 milhões em laboratórios de inteligência artificial em São Paulo, Rio de Janeiro e Minas Gerais.',
        isMainNews: false,
        sources: [
          Source(websiteRoot: 'ibm.com', fantasyName: 'IBM Brasil', articleLink: 'https://ibm.com/sample'),
        ],
        publishedAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      NewsHeadline(
        title: 'Tesla Reduz Preços dos Carros Elétricos em 15% no Brasil',
        summary: 'A montadora americana ajustou os valores para aumentar a competitividade no mercado nacional de veículos elétricos.',
        isMainNews: false,
        sources: [
          Source(websiteRoot: 'tesla.com', fantasyName: 'Tesla', articleLink: 'https://tesla.com/sample'),
        ],
        publishedAt: DateTime.now().subtract(const Duration(hours: 8)),
      ),
      NewsHeadline(
        title: 'Google Investe em Startup Brasileira de Energias Renováveis',
        summary: 'A empresa Solar Tech do interior paulista recebeu aporte de US\$ 25 milhões para expansão na América Latina.',
        isMainNews: false,
        sources: [
          Source(websiteRoot: 'google.com', fantasyName: 'Google Ventures', articleLink: 'https://google.com/sample'),
        ],
        publishedAt: DateTime.now().subtract(const Duration(hours: 10)),
      ),
      NewsHeadline(
        title: 'Microsoft Lança Centro de Inovação em Inteligência Artificial no Recife',
        summary: 'O novo hub focará no desenvolvimento de soluções de IA para setores como saúde, educação e agricultura.',
        isMainNews: false,
        sources: [
          Source(websiteRoot: 'microsoft.com', fantasyName: 'Microsoft Brasil', articleLink: 'https://microsoft.com/sample'),
        ],
        publishedAt: DateTime.now().subtract(const Duration(hours: 12)),
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
          _handleNavigation(page);
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
        // TODO: Navigate to channels page
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Página de canais em desenvolvimento')),
        );
        break;
      case BottomNavPage.settings:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const ConfigurationPage(),
          ),
        );
        break;
    }
  }
}
