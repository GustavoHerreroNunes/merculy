import 'package:flutter/material.dart';
import '../../../../core/constants/color_palette.dart';
import '../onboarding_controller.dart';

class TimeSelectorComponent extends StatefulWidget {
  final OnboardingController controller;

  const TimeSelectorComponent({super.key, required this.controller});

  @override
  State<TimeSelectorComponent> createState() => _TimeSelectorComponentState();
}

class _TimeSelectorComponentState extends State<TimeSelectorComponent> {
  String _selectedTime = '07:45';

  @override
  void initState() {
    super.initState();
    // Load existing time from controller
    _selectedTime = widget.controller.state.preferences.frequencyTime;
  }

  Future<void> _selectTime() async {
    // Parse current time more safely
    final timeParts = _selectedTime.split(':');
    final hour = int.tryParse(timeParts[0]) ?? 7;
    final minute = int.tryParse(timeParts[1]) ?? 45;

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour, minute: minute),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary, // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final newTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      setState(() {
        _selectedTime = newTime;
      });

      // Update the controller with current days and new time
      widget.controller.setFrequency(
        widget.controller.state.preferences.frequencyDays,
        newTime,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _selectTime,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.chipUnselected, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.access_time,
              color: AppColors.primary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              _selectedTime,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
