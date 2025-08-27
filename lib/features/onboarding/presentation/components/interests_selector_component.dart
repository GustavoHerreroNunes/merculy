import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../../../core/constants/color_palette.dart';
import '../onboarding_controller.dart';

class InterestsSelectorComponent extends StatefulWidget {
  final OnboardingController controller;

  const InterestsSelectorComponent({super.key, required this.controller});

  @override
  State<InterestsSelectorComponent> createState() => _InterestsSelectorComponentState();
}

class _InterestsSelectorComponentState extends State<InterestsSelectorComponent> {
  final List<String> _predefinedInterests = [
    'Tecnologia',
    'Economia', 
    'Política',
    'Esportes',
    'Entretenimento',
    'Saúde',
    'Ciência',
    'Arte e Cultura',
  ];

  final List<String> _selectedInterests = [];
  final List<TextEditingController> _otherControllers = [];
  final List<FocusNode> _otherFocusNodes = [];

  @override
  void initState() {
    super.initState();
    // Load existing interests from controller
    _selectedInterests.addAll(widget.controller.state.preferences.interests);
    _addOtherField(); // Start with one "Other" field
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
    
    // Update the controller with the new selection
    widget.controller.setInterests(_selectedInterests);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
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
        }),
        ..._otherControllers.asMap().entries.map((entry) {
          int index = entry.key;
          TextEditingController controller = entry.value;
          FocusNode focusNode = _otherFocusNodes[index];
          final hasText = controller.text.isNotEmpty;

          return SizedBox(
            width: 120, // Set a specific width to match chip size
            height: 60, // Match the height of ChoiceChip more closely
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              style: TextStyle(
                color: hasText ? AppColors.chipTextSelected : AppColors.chipTextUnselected,
                fontWeight: FontWeight.bold,
                fontSize: 14, // Match chip text size
              ),
              decoration: InputDecoration(
                hintText: 'Outros...',
                hintStyle: const TextStyle(
                  color: AppColors.chipTextUnselected,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(
                    color: AppColors.chipUnselected,
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(
                    color: AppColors.chipUnselected,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
                fillColor: hasText ? AppColors.chipSelected : Colors.white,
                filled: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onChanged: (text) {
                setState(() {
                  if (text.isNotEmpty && !_selectedInterests.contains(text)) {
                    _selectedInterests.add(text);
                  } else if (text.isEmpty && _selectedInterests.contains(text)) {
                    _selectedInterests.remove(text);
                  }
                });
                // Update the controller with the new selection
                widget.controller.setInterests(_selectedInterests);
              },
            ),
          );
        }),
      ],
    );
  }
}
