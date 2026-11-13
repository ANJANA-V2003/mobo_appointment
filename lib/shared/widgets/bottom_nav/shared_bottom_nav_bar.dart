import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';

class SharedBottomNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final List<BottomNavigationBarItem> items;

  const SharedBottomNavBar({
    super.key,
    required this.navigationShell,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return SnakeNavigationBar.color(
      behaviour: SnakeBarBehaviour.pinned,
      snakeShape: SnakeShape.indicator,
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),

      backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,

      snakeViewColor: primaryColor,
      selectedItemColor: isDark ? Colors.white : primaryColor,
      unselectedItemColor:
      isDark ? Colors.grey.shade400 : Colors.grey.shade600,

      showSelectedLabels: true,
      showUnselectedLabels: true,

      currentIndex: navigationShell.currentIndex,

      onTap: (index) {
        navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        );
      },

      items: items,

      selectedLabelStyle: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),

      unselectedLabelStyle: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
      ),

      shadowColor: isDark ? Colors.black26 : Colors.grey.shade200,
      elevation: 8,
      height: 70,
    );
  }
}