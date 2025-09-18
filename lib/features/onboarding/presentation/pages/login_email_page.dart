import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/color_palette.dart';
import '../../../../core/services/google_sign_in_service.dart';
import '../../../../core/utils/backend_api_manager.dart';
import '../onboarding_controller.dart';
import '../../domain/entities/user.dart';
import 'interests_onboarding_page.dart';
import '../../../newsletters/presentation/pages/my_newsletters_screen.dart';

class LoginEmailPage extends StatefulWidget {
  const LoginEmailPage({super.key});

  @override
  State<LoginEmailPage> createState() => _LoginEmailPageState();
}

class _LoginEmailPageState extends State<LoginEmailPage> {
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
          final response = await BackendApiManager.googleLogin(googleAuth.idToken!);
          
          // Update user in onboarding controller
          final controller = context.read<OnboardingController>();
          final user = User.fromJson(response['user']);
          controller.setUser(user);
          
          if (mounted) {
            // Check if user needs onboarding (new user or incomplete profile)
            if (user.interests.isEmpty) {
              // New user - needs to complete onboarding
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => InterestsOnboardingPage(userName: user.name),
                ),
              );
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
          'Entrar',
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
              const Text(
                'Digite seu email para entrar',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                  color: AppColors.textMedium,
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
                          // Save email to controller and advance to password
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
