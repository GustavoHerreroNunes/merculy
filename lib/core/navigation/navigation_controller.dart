import 'package:flutter/material.dart';

enum BottomNavPage {
  newsletters,
  saved,
  channels,
  settings,
}

class NavigationController extends ChangeNotifier {
  BottomNavPage _currentPage = BottomNavPage.newsletters;

  BottomNavPage get currentPage => _currentPage;

  void setCurrentPage(BottomNavPage page) {
    if (_currentPage != page) {
      _currentPage = page;
      notifyListeners();
    }
  }

  static BottomNavPage? getPageFromRoute(String? routeName) {
    if (routeName == null) return null;
    
    if (routeName.contains('newsletters') || routeName.contains('MyNewslettersScreen')) {
      return BottomNavPage.newsletters;
    } else if (routeName.contains('saved')) {
      return BottomNavPage.saved;
    } else if (routeName.contains('channels')) {
      return BottomNavPage.channels;
    } else if (routeName.contains('settings') || routeName.contains('configuration')) {
      return BottomNavPage.settings;
    }
    
    return null;
  }
}
