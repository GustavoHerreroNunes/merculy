import 'package:flutter/material.dart';
import '../domain/entities/user.dart';
import '../domain/entities/user_preferences.dart';
import 'onboarding_state.dart';

class OnboardingController extends ChangeNotifier {
  User? _user;
  UserPreferences _preferences;
  int _onboardingStep;
  OnboardingFlowType _currentFlow;

  OnboardingController()
      : _preferences = UserPreferences(
          interests: [],
          newsletterFormat: 1,
          frequencyDays: [1],
          frequencyTime: '07:45',
          followedChannels: [],
          followedStories: [],
        ),
        _onboardingStep = 0,
        _currentFlow = OnboardingFlowType.login;

  // Getters
  User? get user => _user;
  UserPreferences get preferences => _preferences;
  int get onboardingStep => _onboardingStep;
  OnboardingFlowType get currentFlow => _currentFlow;

  // For backward compatibility, provide the state object
  OnboardingState get state => OnboardingState(
    user: _user,
    preferences: _preferences,
    onboardingStep: _onboardingStep,
    currentFlow: _currentFlow,
  );

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  void setInterests(List<String> interests) {
    _preferences = UserPreferences(
      interests: interests,
      newsletterFormat: _preferences.newsletterFormat,
      frequencyDays: _preferences.frequencyDays,
      frequencyTime: _preferences.frequencyTime,
      followedChannels: _preferences.followedChannels,
      followedStories: _preferences.followedStories,
    );
    notifyListeners();
  }

  void setNewsletterFormat(int format) {
    _preferences = UserPreferences(
      interests: _preferences.interests,
      newsletterFormat: format,
      frequencyDays: _preferences.frequencyDays,
      frequencyTime: _preferences.frequencyTime,
      followedChannels: _preferences.followedChannels,
      followedStories: _preferences.followedStories,
    );
    notifyListeners();
  }

  void setFrequency(List<int> days, String time) {
    _preferences = UserPreferences(
      interests: _preferences.interests,
      newsletterFormat: _preferences.newsletterFormat,
      frequencyDays: days,
      frequencyTime: time,
      followedChannels: _preferences.followedChannels,
      followedStories: _preferences.followedStories,
    );
    notifyListeners();
  }

  void setFollowedChannels(List<String> channels) {
    _preferences = UserPreferences(
      interests: _preferences.interests,
      newsletterFormat: _preferences.newsletterFormat,
      frequencyDays: _preferences.frequencyDays,
      frequencyTime: _preferences.frequencyTime,
      followedChannels: channels,
      followedStories: _preferences.followedStories,
    );
    notifyListeners();
  }

  void setFollowedStories(List<String> stories) {
    _preferences = UserPreferences(
      interests: _preferences.interests,
      newsletterFormat: _preferences.newsletterFormat,
      frequencyDays: _preferences.frequencyDays,
      frequencyTime: _preferences.frequencyTime,
      followedChannels: _preferences.followedChannels,
      followedStories: stories,
    );
    notifyListeners();
  }

  void setFlow(OnboardingFlowType flow) {
    _currentFlow = flow;
    notifyListeners();
  }

  void nextStep() {
    print('OnboardingController.nextStep: $_onboardingStep -> ${_onboardingStep + 1}'); // Debug
    _onboardingStep++;
    notifyListeners();
    print('OnboardingController.nextStep: notifyListeners() called'); // Debug
  }

  void previousStep() {
    if (_onboardingStep > 0) {
      _onboardingStep--;
      notifyListeners();
    }
  }
} 