import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'core/constants/color_palette.dart';
import 'core/services/google_sign_in_service.dart';
import 'core/services/web_image_cache_service.dart';
import 'features/onboarding/presentation/pages/welcome_page.dart';
import 'features/onboarding/presentation/pages/login_email_page.dart';
import 'features/onboarding/presentation/pages/login_password_page.dart';
import 'features/onboarding/presentation/pages/first_access_page.dart';
import 'features/onboarding/presentation/pages/password_definition_page.dart';
import 'features/onboarding/presentation/pages/interests_onboarding_page.dart';
import 'features/onboarding/presentation/pages/newsletter_format_onboarding_page.dart';
import 'features/onboarding/presentation/pages/newsletter_frequency_onboarding_page.dart';
// import 'features/onboarding/presentation/pages/newsletter_history_onboarding_page.dart';
import 'features/onboarding/presentation/pages/newsletter_channel_onboarding_page.dart';
import 'features/onboarding/presentation/pages/onboarding_finished_page.dart';
import 'features/onboarding/presentation/onboarding_controller.dart';
import 'features/onboarding/presentation/onboarding_state.dart';
import 'features/newsletters/presentation/pages/my_newsletters_screen.dart';
import 'core/services/token_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  
  // Initialize TokenManager
  await TokenManager.initialize();
  
  // Initialize Image Cache Service
  if (kIsWeb) {
    await WebImageCacheService.initialize();
  } else {
    // For mobile/desktop, you'd use ImageCacheService.initialize();
    print('Mobile/Desktop image cache not implemented yet');
  }
  
  // Initialize Google Sign-In
  try {
    await GoogleSignInService.initializeGoogleSignIn();
  } catch (e) {
    print('Failed to initialize Google Sign-In: $e');
  }
  
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
    final controller = context.watch<OnboardingController>();
    final onboardingStep = controller.state.onboardingStep;
    final currentFlow = controller.state.currentFlow;
    final user = controller.state.user;
    
    switch (onboardingStep) {
      case 0:
        return const WelcomePage();
      case 1:
        // Different paths based on flow
        if (currentFlow == OnboardingFlowType.login) {
          return const LoginEmailPage();
        } else {
          return const FirstAccessPage();
        }
      case 2:
        // Different paths based on flow  
        if (currentFlow == OnboardingFlowType.login) {
          return const LoginPasswordPage();
        } else {
          return const PasswordDefinitionPage();
        }
      case 3:
        // Only registration flow continues to interests
        if (currentFlow == OnboardingFlowType.registration) {
          return InterestsOnboardingPage(userName: user?.name ?? '');
        } else {
          // Login flow should not reach here, but fallback to newsletters
          return const MyNewslettersScreen();
        }
      case 4:
        return const NewsletterFormatOnboardingPage();
      case 5:
        return const NewsletterFrequencyOnboardingPage();
      case 6:
        return const NewsletterChannelOnboardingPage();
      case 7:
        return OnboardingFinishedPage(
          onFinalize: () {
            // Use controller to advance to the final screen or handle completion
            // This assumes there's a final step or a way to signal completion to the controller
            // For now, we'll keep the direct navigation as a fallback if no such controller method exists
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const MyNewslettersScreen(),
              ),
            );
          },
        );
      case 8:
        return const MyNewslettersScreen(); // Assuming this is the final destination after onboarding

      default:
        return const WelcomePage();
    }
  }
}
