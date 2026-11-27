import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/bottom_nav/shared_bottom_nav_bar.dart';

class DashboardScreen extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
  final String title;
  final List<BottomNavigationBarItem> items;

  const DashboardScreen({
    super.key,
    required this.navigationShell,
    required this.title,
    required this.items,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.navigationShell,

      bottomNavigationBar: SharedBottomNavBar(
        navigationShell: widget.navigationShell,
        items: widget.items,
      ),
    );
  }
}
