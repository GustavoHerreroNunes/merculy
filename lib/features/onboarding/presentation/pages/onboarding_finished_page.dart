import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/color_palette.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/utils/backend_api_manager.dart';
import '../onboarding_controller.dart';
import '../helpers/onboarding_helper.dart';
import '../../domain/entities/user.dart';

class OnboardingFinishedPage extends StatefulWidget {
  final VoidCallback onFinalize;

  const OnboardingFinishedPage({
    super.key,
    required this.onFinalize,
  });

  @override
  State<OnboardingFinishedPage> createState() => _OnboardingFinishedPageState();
}

class _OnboardingFinishedPageState extends State<OnboardingFinishedPage> {
  bool _isRegistering = false;
  final BackendApiManager _apiManager = BackendApiManager();

  Future<void> _registerUser() async {
    setState(() {
      _isRegistering = true;
    });

    try {
      final controller = context.read<OnboardingController>();
      final user = controller.state.user;
      final preferences = controller.state.preferences;

      if (user == null) {
        throw Exception('User data not found');
      }

      final response = await _apiManager.registerUser(
        email: user.email,
        name: user.name,
        password: user.password,
        interests: preferences.interests,
        newsletterFormat: OnboardingHelper.convertNewsletterFormatToApi(preferences.newsletterFormat),
        deliveryDays: OnboardingHelper.convertDayNumbersToNames(preferences.frequencyDays),
        deliveryTime: preferences.frequencyTime,
      );

      if (response != null) {
        // Update user with server response (including ID and token)
        final updatedUser = User.fromJson(response);
        controller.setUser(updatedUser.copyWith(
          email: user.email,
          name: user.name,
        ));

        // Registration successful, proceed to main app
        widget.onFinalize();
      }
    } catch (e) {
      setState(() {
        _isRegistering = false;
      });
      
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro no cadastro: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Preferências Definidas',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              
              Image(image: AssetImage(AppAssets.logo), width: 250, height: 250),
              const SizedBox(height: 48.0),
              
              const Text(
                'Pronto, acabamos!',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 16.0,
                    color: AppColors.textMedium,
                    height: 1.5,
                  ),
                  children: [
                    TextSpan(text: 'Você pode mudar suas '),
                    TextSpan(
                      text: 'preferências',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    TextSpan(text: '\nquando quiser nas configurações.'),
                  ],
                ),
              ),
              
              const SizedBox(height: 100),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isRegistering ? null : _registerUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 0,
                  ),
                  child: _isRegistering
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Criando conta...',
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      : const Text(
                          'Finalizar',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
