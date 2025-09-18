import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/color_palette.dart';
import '../../../../core/services/google_sign_in_service.dart';
import '../../../../core/utils/backend_api_manager.dart';
import '../onboarding_controller.dart';
import '../onboarding_state.dart';
import '../../domain/entities/user.dart';
import 'interests_onboarding_page.dart';
import 'terms_of_service_page.dart';
import '../../../newsletters/presentation/pages/my_newsletters_screen.dart';

class FirstAccessPage extends StatefulWidget {
  const FirstAccessPage({super.key});

  @override
  State<FirstAccessPage> createState() => _FirstAccessPageState();
}

class _FirstAccessPageState extends State<FirstAccessPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _isEmailValid = false;
  bool _isGoogleSignInLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _validateEmail() {
    final bool isValid = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(_emailController.text);
    setState(() {
      _isEmailValid = isValid;
    });
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isGoogleSignInLoading = true;
    });

    try {
      final account = await GoogleSignInService.signInWithGoogle();
      
      if (account != null) {
        // Get authentication details
        final googleAuth = await account.authentication;
        
        if (googleAuth.idToken != null) {
          // Send token to backend
          print('[googleAuth] ${googleAuth.idToken}');
          final response = await BackendApiManager.googleLogin(googleAuth.idToken!);
          print('[step 2] Response: $response');
          
          // Update user in onboarding controller
          final controller = context.read<OnboardingController>();
          final user = User.fromJson(response['user']);
          controller.setUser(user);
          print(response['user']);
          print('[step 3] User: ${user.name}, hasInterests: ${user.interests.isNotEmpty}');
          
          if (mounted) {
            // Check if user needs onboarding (new user or incomplete profile)
            if (user.interests.isEmpty) {
              // New user - needs to complete onboarding
              // Set the controller to registration flow and advance to interests step
              print('[Google Sign-in] Current step: ${controller.onboardingStep}');
              controller.setFlow(OnboardingFlowType.registration);
              print('[Google Sign-in] Set flow to registration');
              
              // We are currently at step 1 (FirstAccessPage), need to go to step 3 (InterestsOnboardingPage)
              controller.nextStep(); // step 1 -> 2 (PasswordDefinitionPage)
              print('[Google Sign-in] Advanced to step: ${controller.onboardingStep}');
              controller.nextStep(); // step 2 -> 3 (InterestsOnboardingPage)  
              print('[Google Sign-in] Advanced to step: ${controller.onboardingStep}');
            } else {
              // Existing user with complete profile - go to main app
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const MyNewslettersScreen(),
                ),
              );
            }
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Erro ao obter token do Google'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login com Google cancelado'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleSignInLoading = false;
        });
      }
    }
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
          onPressed: () {
            context.read<OnboardingController>().previousStep();
          },
        ),
        title: const Text(
          'Primeiro Acesso',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 16.0),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 14.0,
                    color: AppColors.textMedium,
                  ),
                  children: <TextSpan>[
                    const TextSpan(
                      text: 'Ao continuar, você concorda com nossos ',
                    ),
                    TextSpan(
                      text: 'Termos de Uso',
                      style: TextStyle(
                        color: AppColors.primary,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const TermsOfServicePage(),
                            ),
                          );
                        },
                    ),
                    const TextSpan(
                      text: ' e ',
                    ),
                    TextSpan(
                      text: 'Política de Privacidade.',
                      style: TextStyle(
                        color: AppColors.primary,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const TermsOfServicePage(),
                            ),
                          );
                        },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32.0),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'example@email.com',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                  errorText: _isEmailValid || _emailController.text.isEmpty
                      ? null
                      : 'Please enter a valid email',
                ),
              ),
              const SizedBox(height: 24.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isEmailValid
                      ? () {
                          // Save email to controller and advance onboarding
                          final controller = context.read<OnboardingController>();
                          final user = controller.state.user;
                          controller.setUser(
                            user == null
                              ? User(id: '', name: '', email: _emailController.text, password: '')
                              : User(id: user.id, name: user.name, email: _emailController.text, password: user.password),
                          );
                          controller.nextStep();
                        }
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
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24.0),
              const Text(
                'OR',
                style: TextStyle(
                  fontSize: 16.0,
                  color: AppColors.textMedium,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isGoogleSignInLoading ? null : _handleGoogleSignIn,
                  icon: _isGoogleSignInLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.textDark),
                          ),
                        )
                      : Image.network(
                          'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png',
                          height: 24.0,
                          width: 24.0,
                          color: Colors.red,
                        ),
                  label: Text(
                    _isGoogleSignInLoading ? 'Entrando...' : 'Continue com Google',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonGoogle,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 0,
                    side: const BorderSide(color: AppColors.border, width: 1.0),
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