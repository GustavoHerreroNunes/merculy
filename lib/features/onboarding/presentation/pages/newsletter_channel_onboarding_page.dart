import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/color_palette.dart';
import '../../../../core/constants/app_assets.dart';
import '../onboarding_controller.dart';

class NewsletterChannelOnboardingPage extends StatefulWidget {
  const NewsletterChannelOnboardingPage({super.key});

  @override
  State<NewsletterChannelOnboardingPage> createState() => _NewsletterChannelOnboardingPageState();
}

class _NewsletterChannelOnboardingPageState extends State<NewsletterChannelOnboardingPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, dynamic>> _channels = [
    {'name': 'Other Brasil', 'icon': Icons.language},
    {'name': 'HNC', 'icon': Icons.science},
    {'name': 'Notícia em Foco', 'icon': Icons.radio},
    {'name': 'Agora', 'icon': Icons.flash_on},
    {'name': 'Coffee News', 'icon': Icons.coffee},
    {'name': 'O Analógico', 'icon': Icons.memory},
    // Add more as needed
  ];
  final Set<String> _followedChannels = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredChannels = _channels.where((c) => c['name'].toLowerCase().contains(_searchController.text.toLowerCase())).toList();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.read<OnboardingController>().previousStep(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(AppAssets.logo, width: 60, height: 60),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Ótimo, estamos quase acabando!',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                'Gostaria de seguir algum canal de notícias?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Procure...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.textMedium),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  itemCount: filteredChannels.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemBuilder: (context, i) {
                    final channel = filteredChannels[i];
                    final followed = _followedChannels.contains(channel['name']);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (followed) {
                            _followedChannels.remove(channel['name']);
                          } else {
                            _followedChannels.add(channel['name']);
                          }
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: followed ? AppColors.primary : AppColors.border,
                            width: 2,
                          ),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(channel['icon'], size: 36, color: AppColors.primary),
                            const SizedBox(height: 8),
                            Text(
                              channel['name'],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textDark,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: followed ? AppColors.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.primary, width: 1),
                              ),
                              child: Text(
                                followed ? 'Seguindo' : 'Follow',
                                style: TextStyle(
                                  color: followed ? Colors.white : AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<OnboardingController>().setFollowedChannels(_followedChannels.toList());
                        context.read<OnboardingController>().nextStep();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      context.read<OnboardingController>().setFollowedChannels([]);
                      context.read<OnboardingController>().nextStep();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textMedium,
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    child: const Text('Pular'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
} 