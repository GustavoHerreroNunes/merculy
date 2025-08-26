import 'package:flutter/material.dart';
import '../../../../core/constants/color_palette.dart';
import '../../../../core/constants/app_assets.dart';

class OnboardingFinishedPage extends StatelessWidget {
  final VoidCallback onFinalize;

  const OnboardingFinishedPage({
    super.key,
    required this.onFinalize,
  });

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
                  onPressed: onFinalize,
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
