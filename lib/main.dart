import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/color_palette.dart';
import 'features/onboarding/presentation/pages/welcome_page.dart';
import 'features/onboarding/presentation/pages/first_access_page.dart';
import 'features/onboarding/presentation/pages/password_definition_page.dart';
import 'features/onboarding/presentation/pages/welcome_onboarding_page.dart';
import 'features/onboarding/presentation/pages/interests_onboarding_page.dart';
import 'features/onboarding/presentation/pages/newsletter_format_onboarding_page.dart';
import 'features/onboarding/presentation/pages/newsletter_frequency_onboarding_page.dart';
import 'features/onboarding/presentation/pages/newsletter_history_onboarding_page.dart';
import 'features/onboarding/presentation/pages/newsletter_channel_onboarding_page.dart';
import 'features/onboarding/presentation/onboarding_controller.dart';

void main() {
  runApp(const MerculyApp());
}

class MerculyApp extends StatelessWidget {
  const MerculyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OnboardingController(),
      child: MaterialApp(
      title: 'Merculy',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: 'Inter',
          scaffoldBackgroundColor: AppColors.background,
        ),
        home: const OnboardingFlow(),
      ),
    );
  }
}

class OnboardingFlow extends StatelessWidget {
  const OnboardingFlow({super.key});

  @override
  Widget build(BuildContext context) {
    final onboardingStep = context.watch<OnboardingController>().state.onboardingStep;
    switch (onboardingStep) {
      case 0:
        return const WelcomePage();
      case 1:
        return const FirstAccessPage();
      case 2:
        return const PasswordDefinitionPage();
      case 3:
        return const WelcomeOnboardingPage();
      case 4:
        // You may want to pass userName from controller.state.user?.name
        return const InterestsOnboardingPage(userName: '');
      case 5:
        return const NewsletterFormatOnboardingPage();
      case 6:
        return const NewsletterFrequencyOnboardingPage();
      case 7:
        return const NewsletterHistoryOnboardingPage();
      case 8:
        return const NewsletterChannelOnboardingPage();
      default:
        return const WelcomePage();
    }
  }
}
