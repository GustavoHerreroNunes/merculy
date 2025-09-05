import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/color_palette.dart';
import '../../../../core/components/bottom_navigation_component.dart';
import '../../../../core/navigation/navigation_controller.dart';
import '../../../../core/utils/backend_api_manager.dart';
import '../../../../main.dart';
import '../../../onboarding/presentation/onboarding_controller.dart';
import '../../../onboarding/presentation/components/interests_selector_component.dart';
import '../../../onboarding/presentation/components/weekday_selector_component.dart';
import '../../../onboarding/presentation/components/time_selector_component.dart';
import '../../../onboarding/presentation/helpers/onboarding_helper.dart';
import '../../../newsletters/presentation/pages/channels_screen.dart';

class ConfigurationPage extends StatefulWidget {
  const ConfigurationPage({super.key});

  @override
  State<ConfigurationPage> createState() => _ConfigurationPageState();
}

class _ConfigurationPageState extends State<ConfigurationPage> {
  bool _isEditingAccount = false;
  bool _isLoadingUser = true;
  bool _isSavingAccount = false;
  bool _isSavingPreferences = false;
  
  // Controllers for account information
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();
  
  // User data - will be loaded from API
  String _userName = '';
  String _userEmail = '';
  final String _hiddenPassword = '••••••••••••';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    print("loaded");
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _newPasswordController.dispose();
    _currentPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      // Load user data from API
      final userData = await BackendApiManager.getCurrentUser();
      print('DEBUG - Raw user data: $userData');
      
      // Debug: Get session info
      try {
        final sessionInfo = await BackendApiManager.getSessionInfo();
        print('DEBUG - Session info in _loadUserData: $sessionInfo');
      } catch (e) {
        print('DEBUG - Failed to get session info: $e');
      }
      
      // Extract user data from nested structure
      final userInfo = userData['user'] as Map<String, dynamic>?;
      print('DEBUG - Extracted user info: $userInfo');
      
      setState(() {
        _userName = userInfo?['name'] ?? '';
        _userEmail = userInfo?['email'] ?? '';
        _nameController.text = _userName;
        _emailController.text = _userEmail;
        _isLoadingUser = false;
      });
      
      print('DEBUG - Set state with name: $_userName, email: $_userEmail');
    
      // if (user != null && user.token != null) {
      //   _authToken = user.token;
        
        
      // } else {
      //   // Fallback: use data from controller if no token
      //   print("Fallback");
      //   setState(() {
      //     _userName = user?.name ?? '';
      //     _userEmail = user?.email ?? '';
      //     _nameController.text = _userName;
      //     _emailController.text = _userEmail;
      //     _isLoadingUser = false;
      //   });
      // }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _isLoadingUser = false;
      });
      
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar dados do usuário: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
          body: _isLoadingUser 
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 100.0), // Added bottom padding for nav bar
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Account and Access Section
                    _buildAccountSection(),
                    
                    const SizedBox(height: 32),
                    
                    // Logout Button Section
                    _buildLogoutSection(),
                    
                    const SizedBox(height: 32),
                    
                    // Preferences Section
                    _buildPreferencesSection(controller),
                  ],
                ),
              ),
          bottomNavigationBar: BottomNavigationComponent(
            forcePage: BottomNavPage.settings, // Explicitly set as settings page
            onPageChanged: (page) {
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
                onTap: _isSavingAccount ? null : _toggleAccountEditing,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: _isSavingAccount
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
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
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header with Save Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.tune,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Preferências',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _isSavingPreferences ? null : _savePreferences,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: _isSavingPreferences
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        Icons.check,
                        color: AppColors.primary,
                        size: 20,
                      ),
                ),
              ),
            ],
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

  void _toggleAccountEditing() async {
    if (_isEditingAccount) {
      // Validate fields before saving
      if (_canSaveAccountChanges()) {
        // Save changes logic here
        await _saveAccountChanges();
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

  Future<void> _saveAccountChanges() async {
    setState(() {
      _isSavingAccount = true;
    });

    try {
      bool hasPasswordChange = _newPasswordController.text.isNotEmpty;
      bool hasUserInfoChange = _nameController.text != _userName || _emailController.text != _userEmail;

      // Case 1: Password change requested
      if (hasPasswordChange) {
        // Change password first
        await BackendApiManager.changePassword(
          currentPassword: _currentPasswordController.text,
          newPassword: _newPasswordController.text,
        );
      }

      // Case 2: User info change (always do this if there are changes, even with password change)
      if (hasUserInfoChange) {
        await BackendApiManager.updateUser(
          name: _nameController.text,
          email: _emailController.text,
        );
      }

      // Update local state
      setState(() {
        _userName = _nameController.text;
        _userEmail = _emailController.text;
        _isEditingAccount = false;
        _isSavingAccount = false;
      });
      
      // Clear password fields
      _newPasswordController.clear();
      _currentPasswordController.clear();
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Informações atualizadas com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSavingAccount = false;
      });
      
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar informações'),
            backgroundColor: Colors.red,
          ),
        );
      }
      print("[DEBUG - Config] Error to update user info: $e");
    }
  }

  Future<void> _savePreferences() async {
    setState(() {
      _isSavingPreferences = true;
    });

    try {
      final controller = context.read<OnboardingController>();
      final user = controller.user;
      
      if (user == null) {
        throw Exception('Usuário não encontrado');
      }

      // Convert preferences to API format
      await BackendApiManager.updateProfile(
        userId: user.id,
        interests: controller.preferences.interests,
        deliveryDays: OnboardingHelper.convertDayNumbersToNames(controller.preferences.frequencyDays),
        format: OnboardingHelper.convertNewsletterFormatToApi(controller.preferences.newsletterFormat),
        deliveryTime: controller.preferences.frequencyTime,
        followedChannels: controller.preferences.followedChannels
      );

      setState(() {
        _isSavingPreferences = false;
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Preferências atualizadas com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSavingPreferences = false;
      });
      
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar preferências: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const ChannelsScreen(),
            settings: const RouteSettings(name: '/channels'),
          ),
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

  Widget _buildLogoutSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
            children: [
              Icon(
                Icons.logout,
                color: Colors.red[600],
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Sair da Conta',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          const Text(
            'Ao fazer logout, você será redirecionado para a tela de login.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textMedium,
              height: 1.5,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Logout Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _showLogoutConfirmation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Fazer Logout',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Logout'),
          content: const Text('Tem certeza de que deseja sair da sua conta?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performLogout();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red[600],
              ),
              child: const Text('Sair'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLogout() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Call the logout API
      await BackendApiManager.logout();

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Navigate to welcome page and clear the navigation stack
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => ChangeNotifierProvider(
              create: (_) => OnboardingController(),
              child: const OnboardingFlow(),
            ),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      // Close loading dialog if still showing
      if (mounted) Navigator.of(context).pop();

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao fazer logout: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
