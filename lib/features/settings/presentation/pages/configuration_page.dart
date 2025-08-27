import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/color_palette.dart';
import '../../../../core/components/bottom_navigation_component.dart';
import '../../../onboarding/presentation/onboarding_controller.dart';
import '../../../onboarding/presentation/components/interests_selector_component.dart';
import '../../../onboarding/presentation/components/weekday_selector_component.dart';
import '../../../onboarding/presentation/components/time_selector_component.dart';

class ConfigurationPage extends StatefulWidget {
  const ConfigurationPage({super.key});

  @override
  State<ConfigurationPage> createState() => _ConfigurationPageState();
}

class _ConfigurationPageState extends State<ConfigurationPage> {
  bool _isEditingAccount = false;
  BottomNavPage _currentPage = BottomNavPage.settings;
  
  // Controllers for account information
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();
  
  // Mock user data - replace with actual user data
  String _userName = 'Maria';
  String _userEmail = 'maria@example.com';
  final String _hiddenPassword = '••••••••••••';

  @override
  void initState() {
    super.initState();
    _nameController.text = _userName;
    _emailController.text = _userEmail;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _newPasswordController.dispose();
    _currentPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingController>(
      builder: (context, controller, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Configurações',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            centerTitle: false,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 100.0), // Added bottom padding for nav bar
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Account and Access Section
                _buildAccountSection(),
                
                const SizedBox(height: 32),
                
                // Preferences Section
                _buildPreferencesSection(controller),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationComponent(
            currentPage: _currentPage,
            onPageChanged: (page) {
              setState(() {
                _currentPage = page;
              });
              _handleNavigation(page);
            },
          ),
        );
      },
    );
  }

  Widget _buildAccountSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.edit,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Conta e Acesso',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _toggleAccountEditing,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    _isEditingAccount ? Icons.check : Icons.edit,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Account Information Fields
          _buildAccountField('Nome', _userName, _nameController, false),
          const SizedBox(height: 16),
          _buildAccountField('Email', _userEmail, _emailController, false),
          const SizedBox(height: 16),
          _buildAccountField('Senha', _hiddenPassword, null, true),
          
          // New Password Fields (only when editing)
          if (_isEditingAccount) ...[
            const SizedBox(height: 16),
            _buildPasswordField('Nova senha', _newPasswordController, false),
            
            // Current Password Field (only if new password is filled)
            if (_newPasswordController.text.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildPasswordField('Senha atual', _currentPasswordController, true),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildAccountField(String label, String value, TextEditingController? controller, bool isPassword) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textMedium,
          ),
        ),
        const SizedBox(height: 8),
        
        if (!_isEditingAccount || isPassword)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textDark,
              ),
            ),
          )
        else
          TextField(
            controller: controller,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textDark,
            ),
          ),
      ],
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller, bool isRequired) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textMedium,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: true,
          onChanged: (value) {
            setState(() {}); // Trigger rebuild to show/hide current password field
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildPreferencesSection(OnboardingController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          const Text(
            'Preferências',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Interests Subsection
          const Text(
            'Assuntos',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          InterestsSelectorComponent(controller: controller),
          
          const SizedBox(height: 24),
          
          // Days of Week Subsection
          const Text(
            'Dias da Semana',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          WeekdaySelectorComponent(controller: controller),
          
          const SizedBox(height: 24),
          
          // Time of Day Subsection
          const Text(
            'Horário do Dia',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          TimeSelectorComponent(controller: controller),
        ],
      ),
    );
  }

  void _toggleAccountEditing() {
    if (_isEditingAccount) {
      // Validate fields before saving
      if (_canSaveAccountChanges()) {
        // Save changes logic here
        _saveAccountChanges();
        setState(() {
          _isEditingAccount = false;
        });
      } else {
        // Show validation error
        _showValidationError();
      }
    } else {
      setState(() {
        _isEditingAccount = true;
        _nameController.text = _userName;
        _emailController.text = _userEmail;
      });
    }
  }

  bool _canSaveAccountChanges() {
    // Check if all required fields are filled
    if (_nameController.text.isEmpty || _emailController.text.isEmpty) {
      return false;
    }
    
    // If new password is filled, current password must also be filled
    if (_newPasswordController.text.isNotEmpty && _currentPasswordController.text.isEmpty) {
      return false;
    }
    
    return true;
  }

  void _saveAccountChanges() {
    // Update user data
    setState(() {
      _userName = _nameController.text;
      _userEmail = _emailController.text;
    });
    
    // Clear password fields
    _newPasswordController.clear();
    _currentPasswordController.clear();
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Informações atualizadas com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _handleNavigation(BottomNavPage page) {
    switch (page) {
      case BottomNavPage.newsletters:
        Navigator.of(context).pop(); // Go back to newsletters screen
        break;
      case BottomNavPage.saved:
        // TODO: Navigate to saved articles page
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Página de salvos em desenvolvimento')),
        );
        break;
      case BottomNavPage.channels:
        // TODO: Navigate to channels page
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Página de canais em desenvolvimento')),
        );
        break;
      case BottomNavPage.settings:
        // Already on settings page, do nothing
        break;
    }
  }

  void _showValidationError() {
    String errorMessage = 'Por favor, preencha todos os campos obrigatórios.';
    
    if (_newPasswordController.text.isNotEmpty && _currentPasswordController.text.isEmpty) {
      errorMessage = 'Para alterar a senha, é necessário informar a senha atual.';
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
      ),
    );
  }
}
