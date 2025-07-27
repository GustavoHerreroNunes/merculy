import 'package:flutter/material.dart';
import '../../../core/constants/color_palette.dart';

enum BottomNavPage {
  newsletters,
  saved,
  channels,
  settings,
}

class BottomNavigationComponent extends StatelessWidget {
  final BottomNavPage currentPage;
  final Function(BottomNavPage) onPageChanged;

  const BottomNavigationComponent({
    super.key,
    required this.currentPage,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMedium,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 12,
        ),
        currentIndex: _getCurrentIndex(),
        onTap: (index) => _handleTap(index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Newsletters',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_outline),
            activeIcon: Icon(Icons.bookmark),
            label: 'Salvas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Canais',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Config',
          ),
        ],
      ),
    );
  }

  int _getCurrentIndex() {
    switch (currentPage) {
      case BottomNavPage.newsletters:
        return 0;
      case BottomNavPage.saved:
        return 1;
      case BottomNavPage.channels:
        return 2;
      case BottomNavPage.settings:
        return 3;
    }
  }

  void _handleTap(int index) {
    switch (index) {
      case 0:
        onPageChanged(BottomNavPage.newsletters);
        break;
      case 1:
        onPageChanged(BottomNavPage.saved);
        break;
      case 2:
        onPageChanged(BottomNavPage.channels);
        break;
      case 3:
        onPageChanged(BottomNavPage.settings);
        break;
    }
  }
}
