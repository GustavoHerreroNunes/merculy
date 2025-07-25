import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/color_palette.dart';
import '../../../../core/constants/app_assets.dart';
import '../onboarding_controller.dart';

class NewsletterHistoryOnboardingPage extends StatefulWidget {
  const NewsletterHistoryOnboardingPage({super.key});

  @override
  State<NewsletterHistoryOnboardingPage> createState() => _NewsletterHistoryOnboardingPageState();
}

class _NewsletterHistoryOnboardingPageState extends State<NewsletterHistoryOnboardingPage> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _suggestions = [
    'Petrobras no Baixo do Amazonas',
    'Tarifas EUA',
    'Eleições 2024',
  ];
  String? _selectedSuggestion;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _saveAndContinue() {
    final story = _controller.text.trim();
    if (story.isNotEmpty) {
      context.read<OnboardingController>().setFollowedStories([story]);
    }
    context.read<OnboardingController>().nextStep();
  }

  void _skip() {
    context.read<OnboardingController>().setFollowedStories([]);
    context.read<OnboardingController>().nextStep();
  }

  @override
  Widget build(BuildContext context) {
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
                      'Uma ótima frequência para se manter informado!',
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
                'Gostaria de ser atualizado sobre alguma história?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Digite a história...',
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
              ..._suggestions.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ListTile(
                  tileColor: _selectedSuggestion == s ? AppColors.primary.withOpacity(0.1) : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  title: Text(s, style: TextStyle(color: AppColors.textDark)),
                  trailing: _selectedSuggestion == s ? const Icon(Icons.check, color: AppColors.primary) : null,
                  onTap: () {
                    setState(() {
                      _selectedSuggestion = s;
                      _controller.text = s;
                    });
                  },
                ),
              )),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _controller.text.isNotEmpty || _selectedSuggestion != null
                          ? _saveAndContinue
                          : null,
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
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: _skip,
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