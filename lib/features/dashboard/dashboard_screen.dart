import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';

import '../../core/routing/app_routes.dart';
import '../../shared/widgets/bottom_nav/shared_bottom_nav_bar.dart';
import '../login/provider/auth_provider.dart';

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
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          GestureDetector(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: CircleAvatar(),
            ),
            onTap: () {
              context.pushNamed(AppRoutes.profile);
            },
          ),

        ],
      ),

      body: widget.navigationShell,

      bottomNavigationBar: SharedBottomNavBar(
        navigationShell: widget.navigationShell,
        items: widget.items,
      ),
    );
  }
}
