import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/color_palette.dart';
import '../onboarding_controller.dart';

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
              Wrap(
                spacing: 12.0,
                runSpacing: 12.0,
                children: [
                  ..._predefinedInterests.map((interest) {
                    final isSelected = _selectedInterests.contains(interest);
                    return ChoiceChip(
                      label: Text(interest),
                      selected: isSelected,
                      onSelected: (selected) {
                        _toggleInterest(interest);
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
                  }).toList(),
                  ..._otherControllers.asMap().entries.map((entry) {
                    int index = entry.key;
                    TextEditingController controller = entry.value;
                    FocusNode focusNode = _otherFocusNodes[index];

                    return SizedBox(
                      width: 150,
                      child: TextField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          hintText: 'Outro...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                              color: AppColors.chipUnselected,
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                              color: AppColors.chipSelected,
                              width: 1.5,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onTap: () {},
                        onChanged: (text) {
                          if (text.isNotEmpty && !_selectedInterests.contains(text)) {
                            _selectedInterests.add(text);
                          } else if (text.isEmpty && _selectedInterests.contains(text)) {
                            _selectedInterests.remove(text);
                          }
                        },
                        onEditingComplete: () {
                          focusNode.unfocus();
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
                    // Save interests to controller and advance onboarding
                    for (var controller in _otherControllers) {
                      if (controller.text.isNotEmpty && !_selectedInterests.contains(controller.text)) {
                        _selectedInterests.add(controller.text);
                      }
                    }
                    context.read<OnboardingController>().setInterests(List<String>.from(_selectedInterests));
                    context.read<OnboardingController>().nextStep();
                  },
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
            ],
          ),
        ),
      ),
    );
  }
} 