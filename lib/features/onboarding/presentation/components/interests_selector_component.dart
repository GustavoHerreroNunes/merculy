import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../../../core/constants/color_palette.dart';
import '../../../../core/utils/backend_api_manager.dart';
import '../onboarding_controller.dart';

class InterestsSelectorComponent extends StatefulWidget {
  final OnboardingController controller;

  const InterestsSelectorComponent({super.key, required this.controller});

  @override
  State<InterestsSelectorComponent> createState() => _InterestsSelectorComponentState();
}

class _InterestsSelectorComponentState extends State<InterestsSelectorComponent> {
  List<Map<String, dynamic>> _availableTopics = [];
  bool _isLoadingTopics = true;
  String? _errorMessage;
  final List<String> _selectedInterests = [];
  final List<TextEditingController> _otherControllers = [];
  final List<FocusNode> _otherFocusNodes = [];

  @override
  void initState() {
    super.initState();
    // Load existing interests from controller
    _selectedInterests.addAll(widget.controller.state.preferences.interests);
    _loadTopics();
    _addOtherField(); // Start with one "Other" field
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
          {'id': 'tecnologia', 'name': 'Tecnologia', 'icon': 'computer'},
          {'id': 'economia', 'name': 'Economia', 'icon': 'trending_up'},
          {'id': 'politica', 'name': 'Política', 'icon': 'account_balance'},
          {'id': 'esportes', 'name': 'Esportes', 'icon': 'sports_soccer'},
          {'id': 'entretenimento', 'name': 'Entretenimento', 'icon': 'movie'},
          {'id': 'saude', 'name': 'Saúde', 'icon': 'favorite'},
          {'id': 'ciencia', 'name': 'Ciência', 'icon': 'science'},
          {'id': 'arte-cultura', 'name': 'Arte e Cultura', 'icon': 'palette'},
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
    
    // Update the controller with the new selection of ids
    widget.controller.setInterests(_selectedInterests);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingTopics) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    if (_errorMessage != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
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
      );
    }

    return Wrap(
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
