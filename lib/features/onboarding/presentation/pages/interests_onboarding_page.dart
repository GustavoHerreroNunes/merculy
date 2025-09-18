import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/color_palette.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/utils/backend_api_manager.dart';
import '../onboarding_controller.dart';

class InterestsOnboardingPage extends StatefulWidget {
  final String userName;
  const InterestsOnboardingPage({super.key, required this.userName});

  @override
  State<InterestsOnboardingPage> createState() => _InterestsOnboardingPageState();
}

class _InterestsOnboardingPageState extends State<InterestsOnboardingPage> {
  List<Map<String, dynamic>> _availableTopics = [];
  bool _isLoadingTopics = true;
  String? _errorMessage;
  final List<String> _selectedInterests = [];
  final List<TextEditingController> _otherControllers = [];
  final List<FocusNode> _otherFocusNodes = [];

  @override
  void initState() {
    super.initState();
    _loadTopics();
    _addOtherField();
  }

  Future<void> _loadTopics() async {
    try {
      setState(() {
        _isLoadingTopics = true;
        _errorMessage = null;
      });

      final response = await BackendApiManager.getTopics();
      final List<dynamic> topics = response['topics'] ?? [];
      
      setState(() {
        _availableTopics = topics.map((topic) => {
          'id': topic['id'],
          'name': topic['name'],
          'icon': topic['icon'] ?? 'account_balance',
          'primaryColor': topic['primary-color'] ?? '#9C27B0',
          'secondaryColor': topic['secondary-color'] ?? '#E1BEE7',
        }).toList();
        _isLoadingTopics = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar tópicos: $e';
        _isLoadingTopics = false;
        // Fallback to static data in case of error
        _availableTopics = [
          {'id': 'noticias', 'name': 'Notícias'},
          {'id': 'esportes', 'name': 'Esportes'},
          {'id': 'tecnologia', 'name': 'Tecnologia'},
          {'id': 'entretenimento', 'name': 'Entretenimento'},
          {'id': 'financas', 'name': 'Finanças'},
          {'id': 'saude', 'name': 'Saúde'},
        ];
      });
    }
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

    controller.addListener(() {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_otherControllers.last == controller && controller.text.isNotEmpty) {
          if (_otherControllers.isEmpty || _otherControllers.last.text.isNotEmpty) {
            setState(() {
              _addOtherField();
            });
          }
        }
      });
    });

    focusNode.addListener(() {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (!focusNode.hasFocus && controller.text.isEmpty && _otherControllers.length > 1) {
          setState(() {
            final index = _otherControllers.indexOf(controller);
            if (index != -1) {
              controller.dispose();
              _otherControllers.removeAt(index);
              _otherFocusNodes.removeAt(index).dispose();
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

  void _toggleInterest(String topicId) {
    setState(() {
      if (_selectedInterests.contains(topicId)) {
        _selectedInterests.remove(topicId);
      } else {
        _selectedInterests.add(topicId);
      }
    });
    print('Selected interests: $_selectedInterests'); // Debug print
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
              Image.asset(AppAssets.logo, width: 150, height: 150),
              const SizedBox(width: 5),
              Text(
                'Olá ${widget.userName},',
                style: const TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8.0),
              const Text(
                'Quais assuntos te interessam?',
                style: TextStyle(
                  fontSize: 18.0,
                  color: AppColors.textMedium,
                ),
              ),
              const SizedBox(height: 32.0),
              if (_errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red.shade700),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (_isLoadingTopics)
                const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                )
              else
                Wrap(
                  spacing: 12.0,
                  runSpacing: 12.0,
                  children: [
                    ..._availableTopics.map((topic) {
                      final topicId = topic['id'].toString();
                      final isSelected = _selectedInterests.contains(topicId);
                      return ChoiceChip(
                        label: Text(topic['name']),
                        selected: isSelected,
                        onSelected: (selected) {
                          _toggleInterest(topicId);
                        },
                        selectedColor: AppColors.chipSelected,
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.chipTextSelected : AppColors.chipTextUnselected,
                          fontWeight: FontWeight.bold,
                        ),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          side: BorderSide(
                            color: isSelected ? AppColors.chipSelected : AppColors.chipUnselected,
                            width: 1.5,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                      );
                    }).toList()
                  ],
                ),
              const SizedBox(height: 32.0),
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selectedInterests.isNotEmpty ? () {
                        print('Continue button clicked! Selected interests: $_selectedInterests'); // Debug
                        // Save interests to controller and advance onboarding
                        for (var controller in _otherControllers) {
                          if (controller.text.isNotEmpty && !_selectedInterests.contains(controller.text)) {
                            _selectedInterests.add(controller.text);
                          }
                        }
                        print('Final interests being saved: $_selectedInterests'); // Debug
                        context.read<OnboardingController>().setInterests(List<String>.from(_selectedInterests));
                        context.read<OnboardingController>().nextStep(); // This should trigger automatic navigation
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
                        'Continue',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 