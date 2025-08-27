import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/color_palette.dart';
import 'features/onboarding/presentation/pages/welcome_page.dart';
import 'features/onboarding/presentation/pages/first_access_page.dart';
import 'features/onboarding/presentation/pages/password_definition_page.dart';
import 'features/onboarding/presentation/pages/interests_onboarding_page.dart';
import 'features/onboarding/presentation/pages/newsletter_format_onboarding_page.dart';
import 'features/onboarding/presentation/pages/newsletter_frequency_onboarding_page.dart';
// import 'features/onboarding/presentation/pages/newsletter_history_onboarding_page.dart';
import 'features/onboarding/presentation/pages/newsletter_channel_onboarding_page.dart';
import 'features/onboarding/presentation/pages/onboarding_finished_page.dart';
import 'features/onboarding/presentation/onboarding_controller.dart';
import 'features/newsletters/presentation/pages/my_newsletters_screen.dart';
import 'features/onboarding/presentation/pages/welcome_onboarding_page.dart';

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
    final controller = context.read<OnboardingController>();
    final user = controller.state.user;
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
        return InterestsOnboardingPage(userName: user?.name ?? '');
      case 5:
        return const NewsletterFormatOnboardingPage();
      case 6:
        return const NewsletterFrequencyOnboardingPage();
      // case 6:
      //   return const NewsletterHistoryOnboardingPage();
      case 7:
        return const NewsletterChannelOnboardingPage();
      case 8:
        return OnboardingFinishedPage(
          onFinalize: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const MyNewslettersScreen(),
              ),
            );
          },
        );
      default:
        return const WelcomePage();
    }
  }
}
