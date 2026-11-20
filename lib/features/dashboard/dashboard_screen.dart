import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobo_appointment_project/features/profile/providers/profile_provider.dart';
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
  Future<void> _loadProfile() async {
    final profileProvider = context.read<ProfileProvider>();

    if (profileProvider.hasProfile) return;

    final authProvider = context.read<AuthProvider>();

    final client = authProvider.client;
    final userId = authProvider.session?.userId;

    if (client == null || userId == null) {
      return;
    }

    await context.read<ProfileProvider>().fetchProfile(
      client: client,
      userId: userId,
    );
  }

  @override
  void initState() {
    super.initState();
    // TODO: implement initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadProfile();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();

    final profile = profileProvider.profile;
    final avatarBase64 = profile?.avatarBase64;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Dashboard",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          GestureDetector(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: CircleAvatar(
                backgroundImage: avatarBase64 != null && avatarBase64.isNotEmpty
                    ? MemoryImage(base64Decode(avatarBase64))
                    : null,
                child: avatarBase64 == null || avatarBase64.isEmpty
                    ? const Icon(Icons.person, size: 40, color: Colors.grey)
                    : null,
              ),
            ),
            onTap: () {
              context.pushNamed(AppRoutes.profile);
            },
          ),
        ],
        forceMaterialTransparency: true,
      ),

      body: widget.navigationShell,

      bottomNavigationBar: SharedBottomNavBar(
        navigationShell: widget.navigationShell,
        items: widget.items,
      ),
    );
  }
}
