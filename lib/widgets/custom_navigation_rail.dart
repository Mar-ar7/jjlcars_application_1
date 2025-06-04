import 'package:flutter/material.dart';
import '../main.dart';

class CustomNavigationRail extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;

  const CustomNavigationRail({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      backgroundColor: AppColors.cardBackground,
      elevation: 4,
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Text(
          'BB',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.directions_car_outlined),
          selectedIcon: Icon(Icons.directions_car),
          label: Text('Cars'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.cloud_outlined),
          selectedIcon: Icon(Icons.cloud),
          label: Text('Weather'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.mail_outline),
          selectedIcon: Icon(Icons.mail),
          label: Text('Messages'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.grid_view_outlined),
          selectedIcon: Icon(Icons.grid_view),
          label: Text('Dashboard'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.card_giftcard_outlined),
          selectedIcon: Icon(Icons.card_giftcard),
          label: Text('Gifts'),
        ),
      ],
      selectedIconTheme: IconThemeData(color: AppColors.primary),
      unselectedIconTheme: IconThemeData(color: AppColors.textSecondary),
      selectedLabelTextStyle: TextStyle(
        color: AppColors.primary,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelTextStyle: TextStyle(
        color: AppColors.textSecondary,
      ),
    );
  }
} 