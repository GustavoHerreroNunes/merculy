import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/color_palette.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/services/token_manager.dart';
import '../../../../core/utils/backend_api_manager.dart';
import '../onboarding_controller.dart';
import '../onboarding_state.dart';
import '../../../newsletters/presentation/pages/my_newsletters_screen.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool _isCheckingAuth = true;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    try {
      // Check if user has a token
      if (TokenManager.isLoggedIn) {
        print('AUTH: Token found, validating with server...');
        
        // Validate token with server by calling /me endpoint
        final userData = await BackendApiManager.getCurrentUser();
        
        if (userData != null && mounted) {
          print('AUTH: Token is valid, redirecting to home...');
          // Token is valid, redirect to main app
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const MyNewslettersScreen(),
            ),
          );
          return;
        }
      }
      
      print('AUTH: No valid token, showing welcome screen...');
    } catch (e) {
      print('AUTH: Token validation failed: $e');
      // Token is invalid, clear it
      await TokenManager.clearAuthData();
    }
    
    // Show welcome page
    if (mounted) {
      setState(() {
        _isCheckingAuth = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while checking authentication
    if (_isCheckingAuth) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image(image: AssetImage(AppAssets.logo), width: 250, height: 250),
              const Text(
                'Merculy',
                style: TextStyle(
                  fontSize: 36.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Olá! Vamos começar?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.0,
                  color: AppColors.textMedium,
                ),
              ),
              const SizedBox(height: 80.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Set login flow and advance onboarding step
                    final controller = context.read<OnboardingController>();
                    controller.setFlow(OnboardingFlowType.login);
                    controller.nextStep();
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
                    'Entrar',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    // Set registration flow and advance onboarding step
                    final controller = context.read<OnboardingController>();
                    controller.setFlow(OnboardingFlowType.registration);
                    controller.nextStep();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary, width: 2.0),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: const Text(
                    'Primeiro Acesso',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24.0),
            ],
          ),
        ),
      ),
    );
  }
} 