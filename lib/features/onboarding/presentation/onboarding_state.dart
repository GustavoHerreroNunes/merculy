import '../domain/entities/user.dart';
import '../domain/entities/user_preferences.dart';

class OnboardingState {
  User? user;
  UserPreferences preferences;
  int onboardingStep;

  OnboardingState({
    this.user,
    required this.preferences,
    this.onboardingStep = 0,
  });
} 