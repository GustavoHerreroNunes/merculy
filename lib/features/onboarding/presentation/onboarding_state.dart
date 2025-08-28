import '../domain/entities/user.dart';
import '../domain/entities/user_preferences.dart';

enum OnboardingFlowType {
  login,
  registration,
}

class OnboardingState {
  User? user;
  UserPreferences preferences;
  int onboardingStep;
  OnboardingFlowType currentFlow;

  OnboardingState({
    this.user,
    required this.preferences,
    this.onboardingStep = 0,
    this.currentFlow = OnboardingFlowType.login,
  });
} 