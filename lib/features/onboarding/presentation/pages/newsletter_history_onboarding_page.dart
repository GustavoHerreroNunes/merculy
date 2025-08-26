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
  final List<String> _userStories = [];
  final int _maxStories = 3;
  bool _canSave = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateCanSave);
  }

  @override
  void dispose() {
    _controller.removeListener(_updateCanSave);
    _controller.dispose();
    super.dispose();
  }

  void _updateCanSave() {
    setState(() {
      _canSave = _controller.text.trim().isNotEmpty;
    });
  }

  void _addStory() {
    final story = _controller.text.trim();
    if (story.isNotEmpty && _userStories.length < _maxStories) {
      setState(() {
        _userStories.add(story);
        _controller.clear();
      });
    }
  }

  void _removeStory(int index) {
    setState(() {
      _userStories.removeAt(index);
    });
  }

  void _saveAndContinue() {
    context.read<OnboardingController>().setFollowedStories(_userStories);
    context.read<OnboardingController>().nextStep();
  }

  void _skip() {
    context.read<OnboardingController>().setFollowedStories([]);
    context.read<OnboardingController>().nextStep();
  }

  @override
  Widget build(BuildContext context) {
    final bool canAddMore = _userStories.length < _maxStories;

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
                  Image.asset(AppAssets.logo, width: 150, height: 150),
                  const SizedBox(width: 5),
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
              const SizedBox(height: 16),
              const Text(
                'Adicione até 3 histórias que você gostaria de acompanhar',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textMedium,
                ),
              ),
              const SizedBox(height: 24),
              
              // Text field with save button
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      enabled: canAddMore,
                      decoration: InputDecoration(
                        hintText: canAddMore ? 'Digite a história...' : 'Limite de 3 histórias atingido',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: canAddMore ? Colors.white : Colors.grey[200],
                        contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                      ),
                      onSubmitted: canAddMore ? (_) => _addStory() : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: canAddMore && _canSave ? _addStory : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 0,
                    ),
                    child: const Icon(Icons.save, size: 20),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              const Text(
                  'Suas histórias:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: _userStories.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          title: Text(
                            _userStories[index],
                            style: const TextStyle(
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => _removeStory(index),
                          ),
                        ),
                      );
                    },
                  ),
                ),

              
              // Bottom buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _userStories.isNotEmpty ? _saveAndContinue : null,
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