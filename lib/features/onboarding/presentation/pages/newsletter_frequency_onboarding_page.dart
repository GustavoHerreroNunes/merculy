import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/color_palette.dart';
import '../../../../core/constants/app_assets.dart';
import '../onboarding_controller.dart';

class NewsletterFrequencyOnboardingPage extends StatefulWidget {
  const NewsletterFrequencyOnboardingPage({super.key});

  @override
  State<NewsletterFrequencyOnboardingPage> createState() => _NewsletterFrequencyOnboardingPageState();
}

class _NewsletterFrequencyOnboardingPageState extends State<NewsletterFrequencyOnboardingPage> {
  final List<String> _days = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
  final Set<int> _selectedDays = {};
  TimeOfDay _selectedTime = const TimeOfDay(hour: 7, minute: 45);

  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
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
          onPressed: () => context.read<OnboardingController>().previousStep(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(AppAssets.logo, width: 150, height: 150),
                  const SizedBox(width: 5),
                  const Expanded(
                    child: Text(
                      'Preferências anotadas. Agora vamos falar sobre periodicidade.',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                'Com que frequência você quer receber sua newsletter?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Selecione pelo menos um dia da semana',
                style: TextStyle(
                  fontSize: 14.0,
                  color: _selectedDays.isEmpty ? Colors.red : AppColors.textMedium,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 24),
              const Text('Dias da Semana', style: TextStyle(color: AppColors.textMedium, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_days.length, (i) {
                  final selected = _selectedDays.contains(i);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (selected) {
                          _selectedDays.remove(i);
                        } else {
                          _selectedDays.add(i);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: selected ? AppColors.primary : AppColors.border, width: 1.5),
                      ),
                      child: Text(
                        _days[i],
                        style: TextStyle(
                          color: selected ? Colors.white : AppColors.textMedium,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              const Text('Horário do Dia', style: TextStyle(color: AppColors.textMedium, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _pickTime(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border, width: 1.5),
                  ),
                  child: Text(
                    _selectedTime.format(context),
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedDays.isNotEmpty ? () {
                    context.read<OnboardingController>().setFrequency(
                      _selectedDays.toList(),
                      _selectedTime.format(context),
                    );
                    context.read<OnboardingController>().nextStep();
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
} 