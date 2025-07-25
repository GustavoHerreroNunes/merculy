class UserPreferences {
  final List<String> interests;
  final int newsletterFormat; // 0: one per topic, 1: general
  final List<int> frequencyDays; // 0: Sunday, 1: Monday, ...
  final String frequencyTime; // e.g., '07:45'
  final List<String> followedChannels;
  final List<String> followedStories;

  UserPreferences({
    required this.interests,
    required this.newsletterFormat,
    required this.frequencyDays,
    required this.frequencyTime,
    required this.followedChannels,
    required this.followedStories,
  });
} 