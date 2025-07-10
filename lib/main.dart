import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart'; // Import for SchedulerBinding

void main() {
  runApp(const MerculyApp());
}

class MerculyApp extends StatelessWidget {
  const MerculyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Merculy',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Inter', // Assuming 'Inter' font is available or will be added
      ),
      home: const WelcomePage(),
    );
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF7F0), // Light beige background color from the wireframe
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Merculy Mascot Image
              // Replace with your actual image asset
              Image(image: AssetImage('logo.png'), width: 250, height: 250),
              // App Title
              const Text(
                'Merculy',
                style: TextStyle(
                  fontSize: 36.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333), // Dark grey for text
                ),
              ),
              const SizedBox(height: 16.0), // Spacing below the title
              // Welcome Message
              const Text(
                'Olá! Vamos começar?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.0,
                  color: Color(0xFF666666), // Medium grey for text
                ),
              ),
              const SizedBox(height: 80.0), // Spacing before buttons
              // "Entrar" Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Implement navigation to the login page
                    print('Entrar button pressed');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE67E22), // Orange button background
                    foregroundColor: Colors.white, // White text color
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0), // Rounded corners
                    ),
                    elevation: 0, // No shadow
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
              const SizedBox(height: 16.0), // Spacing between buttons
              // "Primeiro Acesso" Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    // Navigate to the FirstAccessPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FirstAccessPage()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFE67E22), // Orange text color
                    side: const BorderSide(color: Color(0xFFE67E22), width: 2.0), // Orange border
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0), // Rounded corners
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
              const SizedBox(height: 24.0), // Spacing at the bottom
            ],
          ),
        ),
      ),
    );
  }
}

class FirstAccessPage extends StatefulWidget {
  const FirstAccessPage({super.key});

  @override
  State<FirstAccessPage> createState() => _FirstAccessPageState();
}

class _FirstAccessPageState extends State<FirstAccessPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _isEmailValid = false;

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
    // Simple email validation regex
    final bool isValid = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(_emailController.text);
    setState(() {
      _isEmailValid = isValid;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF7F0), // Light beige background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous page
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
              // Terms and Privacy Policy Text
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 14.0,
                    color: Color(0xFF666666),
                  ),
                  children: <TextSpan>[
                    const TextSpan(
                      text: 'By continuing, you agree to our ',
                    ),
                    TextSpan(
                      text: 'Terms of Services',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor, // Use primary color for links
                        decoration: TextDecoration.underline,
                      ),
                      // TODO: Add onTap for Terms of Services
                    ),
                    const TextSpan(
                      text: ' and ',
                    ),
                    TextSpan(
                      text: 'Private Policy.',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        decoration: TextDecoration.underline,
                      ),
                      // TODO: Add onTap for Private Policy
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32.0),
              // Email Input Field
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'example@email.com',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none, // No border line
                  ),
                  filled: true,
                  fillColor: Colors.white, // White background for the input field
                  contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                  errorText: _isEmailValid || _emailController.text.isEmpty
                      ? null
                      : 'Please enter a valid email',
                ),
              ),
              const SizedBox(height: 24.0),
              // "Continue" Button (for email)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isEmailValid
                      ? () {
                          // Navigate to the PasswordDefinitionPage
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PasswordDefinitionPage()),
                          );
                        }
                      : null, // Button is disabled if email is not valid
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE67E22), // Orange button background
                    foregroundColor: Colors.white, // White text color
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0), // Rounded corners
                    ),
                    elevation: 0, // No shadow
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
              // OR separator
              const Text(
                'OR',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Color(0xFF666666),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24.0),
              // Social Login Buttons
              // Continue with Google
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement Google login
                    print('Continue with Google pressed');
                  },
                  icon: Image.network(
                    'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png', // Google logo
                    height: 24.0,
                    width: 24.0,
                    color: Colors.red, // Flat Red logo
                  ),
                  label: const Text(
                    'Continue com Google',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFEBEE), // Light Red BG
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 0,
                    side: const BorderSide(color: Color(0xFFDDDDDD), width: 1.0), // Light grey border
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              // Continue with Facebook
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement Facebook login
                    print('Continue with Facebook pressed');
                  },
                  icon: Image.network(
                    'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b8/2021_Facebook_icon.svg/1200px-2021_Facebook_icon.svg.png', // Facebook logo
                    height: 24.0,
                    width: 24.0,
                    // Removed 'color: Colors.blue' to fix the icon display
                  ),
                  label: const Text(
                    'Continue com Facebook',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE3F2FD), // Light Blue BG
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 0,
                    side: const BorderSide(color: Color(0xFFDDDDDD), width: 1.0),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              // Continue with Apple
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement Apple login
                    print('Continue with Apple pressed');
                  },
                  icon: Image.network(
                    'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Apple_logo_black.svg/1200px-Apple_logo_black.svg.png', // Apple logo
                    height: 24.0,
                    width: 24.0,
                    color: Colors.black54, // Dark Gray Border logo (adjust as needed)
                  ),
                  label: const Text(
                    'Continue com Apple',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEEEEEE), // Gray BG
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 0,
                    side: const BorderSide(color: Color(0xFF616161), width: 1.0), // Dark Gray Border
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

class PasswordDefinitionPage extends StatelessWidget {
  const PasswordDefinitionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF7F0), // Light beige background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous page
          },
        ),
        title: const Text(
          'Primeiro Acesso', // Title remains "Primeiro Acesso" as per wireframe
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
              // Terms and Privacy Policy Text (as per wireframe, it's still present)
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 14.0,
                    color: Color(0xFF666666),
                  ),
                  children: <TextSpan>[
                    const TextSpan(
                      text: 'By continuing, you agree to our ',
                    ),
                    TextSpan(
                      text: 'Terms of Services',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor, // Use primary color for links
                        decoration: TextDecoration.underline,
                      ),
                      // TODO: Add onTap for Terms of Services
                    ),
                    const TextSpan(
                      text: ' and ',
                    ),
                    TextSpan(
                      text: 'Private Policy.',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        decoration: TextDecoration.underline,
                      ),
                      // TODO: Add onTap for Private Policy
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32.0),
              // Password Input Field
              TextField(
                obscureText: true, // Hide text for password
                decoration: InputDecoration(
                  labelText: 'Senha',
                  hintText: '********',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none, // No border line
                  ),
                  filled: true,
                  fillColor: Colors.white, // White background for the input field
                  contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                ),
              ),
              const SizedBox(height: 24.0),
              // "Cadastrar" Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to the WelcomeOnboardingPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const WelcomeOnboardingPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE67E22), // Orange button background
                    foregroundColor: Colors.white, // White text color
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0), // Rounded corners
                    ),
                    elevation: 0, // No shadow
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

class WelcomeOnboardingPage extends StatefulWidget {
  const WelcomeOnboardingPage({super.key});

  @override
  State<WelcomeOnboardingPage> createState() => _WelcomeOnboardingPageState();
}

class _WelcomeOnboardingPageState extends State<WelcomeOnboardingPage> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF7F0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Bem vindo!',
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
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image(image: AssetImage('logo.png'), width: 150, height: 150),
              const SizedBox(height: 48.0),
              const Text(
                'Olá! Sou Merculy, e vou te ajudar a acompanhar as notícias.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.0,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 24.0),
              const Text(
                'Qual o seu nome?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 32.0),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Maria', // Placeholder name as per wireframe
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                ),
              ),
              const SizedBox(height: 24.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to InterestsOnboardingPage, passing the name
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InterestsOnboardingPage(userName: _nameController.text),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE67E22),
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
            ],
          ),
        ),
      ),
    );
  }
}

class InterestsOnboardingPage extends StatefulWidget {
  final String userName;
  const InterestsOnboardingPage({super.key, required this.userName});

  @override
  State<InterestsOnboardingPage> createState() => _InterestsOnboardingPageState();
}

class _InterestsOnboardingPageState extends State<InterestsOnboardingPage> {
  final List<String> _predefinedInterests = [
    'Notícias',
    'Esportes',
    'Tecnologia',
    'Entretenimento',
    'Finanças',
    'Saúde',
  ];

  final List<String> _selectedInterests = [];
  final List<TextEditingController> _otherControllers = [];
  final List<FocusNode> _otherFocusNodes = [];

  @override
  void initState() {
    super.initState();
    // Add initial "Outro..." field
    _addOtherField();
  }

  @override
  void dispose() {
    for (var controller in _otherControllers) {
      controller.dispose();
    }
    for (var focusNode in _otherFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _addOtherField() {
    final controller = TextEditingController();
    final focusNode = FocusNode();

    // Listener for adding new 'Outro' field when the last one is typed into
    controller.addListener(() {
      // Defer state update to avoid modifying listeners during iteration
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return; // Ensure widget is still mounted

        // Add new 'Outro' field if the last one is being typed into and is not empty
        if (_otherControllers.last == controller && controller.text.isNotEmpty) {
          // Only add if there isn't already an empty 'Outro' field at the end
          if (_otherControllers.isEmpty || _otherControllers.last.text.isNotEmpty) {
            setState(() {
              _addOtherField();
            });
          }
        }
      });
    });

    // Listener for removing 'Outro' field when it becomes empty and loses focus
    focusNode.addListener(() {
      // Defer state update to avoid modifying listeners during iteration
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return; // Ensure widget is still mounted

        if (!focusNode.hasFocus && controller.text.isEmpty && _otherControllers.length > 1) {
          setState(() {
            final index = _otherControllers.indexOf(controller);
            if (index != -1) {
              controller.dispose();
              _otherControllers.removeAt(index);
              _otherFocusNodes.removeAt(index).dispose();
              // Remove the content from selected interests if it was there (e.g., if user typed, selected, then cleared)
              _selectedInterests.removeWhere((element) => element == controller.text);
            }
          });
        }
      });
    });

    setState(() {
      _otherControllers.add(controller);
      _otherFocusNodes.add(focusNode);
    });
  }

  void _toggleInterest(String interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        _selectedInterests.remove(interest);
      } else {
        _selectedInterests.add(interest);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF7F0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Bem vindo!',
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Olá ${widget.userName},',
                style: const TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 8.0),
              const Text(
                'Quais assuntos te interessam?',
                style: TextStyle(
                  fontSize: 18.0,
                  color: Color(0xFF666666),
                ),
              ),
              const SizedBox(height: 32.0),
              Wrap(
                spacing: 12.0, // horizontal spacing
                runSpacing: 12.0, // vertical spacing
                children: [
                  ..._predefinedInterests.map((interest) {
                    final isSelected = _selectedInterests.contains(interest);
                    return ChoiceChip(
                      label: Text(interest),
                      selected: isSelected,
                      onSelected: (selected) {
                        _toggleInterest(interest);
                      },
                      selectedColor: const Color(0xFFE67E22), // Orange when selected
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF666666),
                        fontWeight: FontWeight.bold,
                      ),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: BorderSide(
                          color: isSelected ? const Color(0xFFE67E22) : const Color(0xFFDDDDDD),
                          width: 1.5,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                    );
                  }).toList(),
                  // Dynamic "Outro..." fields
                  ..._otherControllers.asMap().entries.map((entry) {
                    int index = entry.key;
                    TextEditingController controller = entry.value;
                    FocusNode focusNode = _otherFocusNodes[index];

                    return SizedBox(
                      width: 150, // Adjust width as needed
                      child: TextField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          hintText: 'Outro...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                              color: Color(0xFFDDDDDD),
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                              color: Color(0xFFE67E22),
                              width: 1.5,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onTap: () {
                          // No specific action on tap for selection, focusNode listener handles removal
                        },
                        onChanged: (text) {
                          // If text is entered, add it to selected interests (if not already there)
                          if (text.isNotEmpty && !_selectedInterests.contains(text)) {
                            _selectedInterests.add(text);
                          } else if (text.isEmpty && _selectedInterests.contains(text)) {
                            // If text is cleared, remove it from selected interests
                            _selectedInterests.remove(text);
                          }
                          // The add/remove logic for 'Outro' fields (the widgets themselves) is handled by listeners
                        },
                        onEditingComplete: () {
                          focusNode.unfocus(); // Dismiss keyboard
                        },
                      ),
                    );
                  }).toList(),
                ],
              ),
              const SizedBox(height: 32.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Implement navigation to the next page after interests
                    print('Selected Interests: $_selectedInterests');
                    // Ensure any non-empty custom fields are included in the final list
                    for (var controller in _otherControllers) {
                      if (controller.text.isNotEmpty && !_selectedInterests.contains(controller.text)) {
                        _selectedInterests.add(controller.text);
                      }
                    }
                    print('Final Interests (including custom): $_selectedInterests');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE67E22),
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
            ],
          ),
        ),
      ),
    );
  }
}
