import 'package:flutter/material.dart';
import '../../../../core/constants/color_palette.dart';
import '../onboarding_controller.dart';

class WeekdaySelectorComponent extends StatefulWidget {
  final OnboardingController controller;

  const WeekdaySelectorComponent({super.key, required this.controller});

  @override
  State<WeekdaySelectorComponent> createState() => _WeekdaySelectorComponentState();
}

class _WeekdaySelectorComponentState extends State<WeekdaySelectorComponent> {
  final List<String> _weekdays = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];
  List<int> _selectedDays = [];

  @override
  void initState() {
    super.initState();
    // Load existing days from controller (Monday = 1, Sunday = 7)
    _selectedDays = List.from(widget.controller.state.preferences.frequencyDays);
  }

  void _toggleDay(int dayIndex) {
    setState(() {
      final dayNumber = dayIndex + 1; // Convert from 0-based index to 1-based day number
      if (_selectedDays.contains(dayNumber)) {
        _selectedDays.remove(dayNumber);
      } else {
        _selectedDays.add(dayNumber);
      }
    });

    // Update the controller with current time and selected days
    widget.controller.setFrequency(_selectedDays, widget.controller.state.preferences.frequencyTime);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _weekdays.asMap().entries.map((entry) {
        int index = entry.key;
        String day = entry.value;
        final dayNumber = index + 1; // Convert to 1-based day number
        final isSelected = _selectedDays.contains(dayNumber);

        return GestureDetector(
          onTap: () => _toggleDay(index),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? AppColors.primary : Colors.white,
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.chipUnselected,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                day,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.chipTextUnselected,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
