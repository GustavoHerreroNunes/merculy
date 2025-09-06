import 'package:flutter/material.dart';
import 'package:merculy/features/newsletters/presentation/pages/channels_screen.dart';
import 'package:merculy/features/newsletters/presentation/pages/my_newsletters_screen.dart';
import 'package:merculy/features/settings/presentation/pages/configuration_page.dart';
import '../../../core/constants/color_palette.dart';
import '../navigation/navigation_controller.dart';

class BottomNavigationComponent extends StatelessWidget {
  final Function(BottomNavPage)? onPageChanged;
  final BottomNavPage forcePage; // Add optional explicit page

  const BottomNavigationComponent({
    super.key,
    this.onPageChanged,
    required this.forcePage,
  });

  int _getCurrentIndex(BuildContext context) {
    // Use explicit page if provided, otherwise detect from context
    final currentPage = forcePage;
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

  void _handleTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        if(_getCurrentIndex(context) != 0){
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MyNewslettersScreen(),
            settings: const RouteSettings(name: '/newsletters'))
          );
        }
        break;
      case 1:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Página de salvos em desenvolvimento')),
        );
        // onPageChanged(BottomNavPage.saved);
        break;
      case 2:
        if(_getCurrentIndex(context) != 2){
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const ChannelsScreen(),
            settings: const RouteSettings(name: '/channels'))
          );
        }
        // onPageChanged(BottomNavPage.channels);
        break;
      case 3:
        if(_getCurrentIndex(context) != 3){
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const ConfigurationPage(),
            settings: const RouteSettings(name: '/settings'))
          );
        }
        // onPageChanged(BottomNavPage.settings);
        break;
    }
  }

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
        currentIndex: _getCurrentIndex(context),
        onTap: (index) => _handleTap(context, index),
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
}
