import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/color_palette.dart';
import '../../../../core/utils/backend_api_manager.dart';
import '../onboarding_controller.dart';
import '../../domain/entities/user.dart';
import '../../../newsletters/presentation/pages/my_newsletters_screen.dart';

class LoginPasswordPage extends StatefulWidget {
  const LoginPasswordPage({super.key});

  @override
  State<LoginPasswordPage> createState() => _LoginPasswordPageState();
}

class _LoginPasswordPageState extends State<LoginPasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isPasswordValid = false;
  bool _isLoggingIn = false;
  final BackendApiManager _apiManager = BackendApiManager();

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validatePassword);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_validatePassword);
    _passwordController.dispose();
    super.dispose();
  }

  void _validatePassword() {
    setState(() {
      _isPasswordValid = _passwordController.text.length >= 6;
    });
  }

  void _attemptLogin() async {
    setState(() {
      _isLoggingIn = true;
    });

    try {
      final controller = context.read<OnboardingController>();
      final user = controller.state.user;
      
      if (user == null) {
        throw Exception('Email não encontrado');
      }

      final response = await _apiManager.loginUser(
        email: user.email,
        password: _passwordController.text,
      );

      if (response != null) {
        // Update user with server response (including token)
        final loggedInUser = User.fromJson(response);
        controller.setUser(loggedInUser.copyWith(
          email: user.email,
          name: loggedInUser.name.isNotEmpty ? loggedInUser.name : user.name,
        ));

        // Login successful, navigate to main app
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const MyNewslettersScreen(),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoggingIn = false;
      });
      
      // Show error to user
      String errorMessage = 'Erro no login';
      if (e.toString().contains('401') || e.toString().contains('403')) {
        errorMessage = 'Email ou senha incorretos';
      } else if (e.toString().contains('404')) {
        errorMessage = 'Usuário não encontrado';
      } else {
        errorMessage = 'Erro de conexão. Tente novamente.';
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<OnboardingController>();
    final userEmail = controller.state.user?.email ?? '';

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
              Text(
                'Bem-vindo de volta!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                userEmail,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16.0,
                  color: AppColors.textMedium,
                ),
              ),
              const SizedBox(height: 32.0),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  hintText: '********',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      color: AppColors.textMedium,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // TODO: Implement forgot password
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Funcionalidade de recuperação de senha em desenvolvimento')),
                    );
                  },
                  child: Text(
                    'Esqueceu a senha?',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_isPasswordValid && !_isLoggingIn) ? _attemptLogin : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoggingIn
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
                              'Entrando...',
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      : const Text(
                          'Entrar',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Não tem uma conta? ',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: AppColors.textMedium,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to registration flow
                      context.read<OnboardingController>().previousStep();
                      context.read<OnboardingController>().previousStep();
                      context.read<OnboardingController>().nextStep(); // Go to registration
                    },
                    child: Text(
                      'Cadastre-se',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
