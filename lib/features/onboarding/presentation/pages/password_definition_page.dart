import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/color_palette.dart';
import '../onboarding_controller.dart';
import '../../domain/entities/user.dart';

class PasswordDefinitionPage extends StatefulWidget {
  const PasswordDefinitionPage({super.key});

  @override
  State<PasswordDefinitionPage> createState() => _PasswordDefinitionPageState();
}

class _PasswordDefinitionPageState extends State<PasswordDefinitionPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _isPasswordValid = false;
  bool _isNameValid = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validatePassword);
    _nameController.addListener(_validateName);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_validatePassword);
    _passwordController.dispose();
    _nameController.removeListener(_validateName);
    _nameController.dispose();
    super.dispose();
  }

  void _validatePassword() {
    setState(() {
      _isPasswordValid = _passwordController.text.length >= 6;
    });
  }

  void _validateName() {
    setState(() {
      _isNameValid = _nameController.text.trim().isNotEmpty;
    });
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
                      text: 'By continuing, you agree to our ',
                    ),
                    TextSpan(
                      text: 'Terms of Services',
                      style: TextStyle(
                        color: AppColors.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const TextSpan(
                      text: ' and ',
                    ),
                    TextSpan(
                      text: 'Private Policy.',
                      style: TextStyle(
                        color: AppColors.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32.0),
              TextField(
                controller: _nameController,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  labelText: 'Nome Completo',
                  hintText: 'Seu nome',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _passwordController,
                obscureText: true,
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
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                'A senha deve ter pelo menos 6 caracteres',
                style: TextStyle(
                  fontSize: 12.0,
                  color: _isPasswordValid ? AppColors.textMedium : Colors.red,
                ),
              ),
              const SizedBox(height: 24.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_isPasswordValid && _isNameValid) ? () {
                    // Save password and name to controller and advance onboarding
                    final controller = context.read<OnboardingController>();
                    final user = controller.state.user;
                    controller.setUser(
                      user == null
                        ? User(id: '', name: _nameController.text, email: '', password: _passwordController.text)
                        : User(id: user.id, name: _nameController.text, email: user.email, password: _passwordController.text),
                    );
                    controller.nextStep();
                  } : null,
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
                    'Cadastrar',
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