import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/color_palette.dart';
import '../../../../core/constants/app_assets.dart';
import '../onboarding_controller.dart';

class NewsletterFormatOnboardingPage extends StatefulWidget {
  const NewsletterFormatOnboardingPage({super.key});

  @override
  State<NewsletterFormatOnboardingPage> createState() => _NewsletterFormatOnboardingPageState();
}

class _NewsletterFormatOnboardingPageState extends State<NewsletterFormatOnboardingPage> {
  int _selectedFormat = 1;

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
                      'Legal! Vou buscar notícias sobre esses assuntos.',
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
                'Qual formato de newsletter você prefere?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 24),
              RadioListTile<int>(
                value: 0,
                groupValue: _selectedFormat,
                onChanged: (val) => setState(() => _selectedFormat = val!),
                title: const Text('Uma newsletter para cada assunto', style: TextStyle(color: AppColors.textMedium)),
                activeColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
              ),
              RadioListTile<int>(
                value: 1,
                groupValue: _selectedFormat,
                onChanged: (val) => setState(() => _selectedFormat = val!),
                title: const Text('Uma newsletter geral abordando tudo', style: TextStyle(color: AppColors.textMedium)),
                activeColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<OnboardingController>().setNewsletterFormat(_selectedFormat);
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
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
} 