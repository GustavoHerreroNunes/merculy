import 'package:flutter/material.dart';
import '../domain/entities/user.dart';
import '../domain/entities/user_preferences.dart';
import 'onboarding_state.dart';

class OnboardingController extends ChangeNotifier {
  OnboardingState state;

  OnboardingController()
      : state = OnboardingState(
          preferences: UserPreferences(
            interests: [],
            newsletterFormat: 1,
            frequencyDays: [1],
            frequencyTime: '07:45',
            followedChannels: [],
            followedStories: [],
          ),
        );

  void setUser(User user) {
    state.user = user;
    notifyListeners();
  }

  void setInterests(List<String> interests) {
    state.preferences = UserPreferences(
      interests: interests,
      newsletterFormat: state.preferences.newsletterFormat,
      frequencyDays: state.preferences.frequencyDays,
      frequencyTime: state.preferences.frequencyTime,
      followedChannels: state.preferences.followedChannels,
      followedStories: state.preferences.followedStories,
    );
    notifyListeners();
  }

  void setNewsletterFormat(int format) {
    state.preferences = UserPreferences(
      interests: state.preferences.interests,
      newsletterFormat: format,
      frequencyDays: state.preferences.frequencyDays,
      frequencyTime: state.preferences.frequencyTime,
      followedChannels: state.preferences.followedChannels,
      followedStories: state.preferences.followedStories,
    );
    notifyListeners();
  }

  void setFrequency(List<int> days, String time) {
    state.preferences = UserPreferences(
      interests: state.preferences.interests,
      newsletterFormat: state.preferences.newsletterFormat,
      frequencyDays: days,
      frequencyTime: time,
      followedChannels: state.preferences.followedChannels,
      followedStories: state.preferences.followedStories,
    );
    notifyListeners();
  }

  void setFollowedChannels(List<String> channels) {
    state.preferences = UserPreferences(
      interests: state.preferences.interests,
      newsletterFormat: state.preferences.newsletterFormat,
      frequencyDays: state.preferences.frequencyDays,
      frequencyTime: state.preferences.frequencyTime,
      followedChannels: channels,
      followedStories: state.preferences.followedStories,
    );
    notifyListeners();
  }

  void setFollowedStories(List<String> stories) {
    state.preferences = UserPreferences(
      interests: state.preferences.interests,
      newsletterFormat: state.preferences.newsletterFormat,
      frequencyDays: state.preferences.frequencyDays,
      frequencyTime: state.preferences.frequencyTime,
      followedChannels: state.preferences.followedChannels,
      followedStories: stories,
    );
    notifyListeners();
  }

  void nextStep() {
    state.onboardingStep++;
    notifyListeners();
  }

  void previousStep() {
    if (state.onboardingStep > 0) {
      state.onboardingStep--;
      notifyListeners();
    }
  }
} 