class OnboardingHelper {
  static List<String> convertDayNumbersToNames(List<int> dayNumbers) {
    const dayMap = {
      1: 'monday',
      2: 'tuesday',
      3: 'wednesday',
      4: 'thursday',
      5: 'friday',
      6: 'saturday',
      7: 'sunday',
    };
    
    return dayNumbers.map((dayNumber) => dayMap[dayNumber] ?? 'monday').toList();
  }

  static String convertNewsletterFormatToApi(int format) {
    switch (format) {
      case 1:
        return 'single';
      case 2:
        return 'multiple';
      default:
        return 'single';
    }
  }
}
