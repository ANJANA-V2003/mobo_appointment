import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:mobo_appointment_project/core/providers/role_provider.dart';
import 'package:mobo_appointment_project/core/routing/app_routes.dart';
import 'package:mobo_appointment_project/core/theme/app_theme.dart';
import 'package:mobo_appointment_project/features/appointments/services/appointment_service.dart';
import 'package:mobo_appointment_project/features/profile/providers/profile_provider.dart';
import 'package:provider/provider.dart';

import '../../login/provider/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  static const Color primaryColor = AppTheme.primaryColor;
  static const Color secondaryText = AppTheme.secondaryText;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _showLogoutDialog(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? Colors.grey[900] : Colors.white,
          title: const Text('Confirm Logout'),
          content: const Text(
            'Are you sure you want to log out ?   '
            'Your session will be ended.',
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ProfileScreen.primaryColor,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: ProfileScreen.primaryColor,
                          width: 2,
                        ),
                        borderRadius: BorderRadiusGeometry.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: ProfileScreen.primaryColor),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ProfileScreen.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(12),
                      ),
                    ),
                    onPressed: () {
                      _logout();
                    },
                    child: const Text(
                      'Logout',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    if (shouldLogout == true && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Dummy logout successful')));
    }
  }

  void _onSettingsTap(BuildContext context) {
    context.pushNamed(AppRoutes.settings);
  }

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

  Future<void> _logout() async {
    context.read<ProfileProvider>().clearProfile();

    await context.read<AuthProvider>().logout();

    if (!mounted) return;

    context.goNamed(AppRoutes.splash);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadProfile();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profileProvider = context.watch<ProfileProvider>();

    final profile = profileProvider.profile;
    final avatarBase64 = profile?.avatarBase64;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(), // change the route of popping
          icon: HugeIcon(icon: (HugeIconsStrokeRounded.chevronLeft)),
        ),
        title: const Text(
          'Configuration',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w600,
            // color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
        child: Column(
          children: [
            //profile card
            InkWell(
              onTap: () => context.pushNamed(AppRoutes.profileDetails),
              child: Container(
                height: 135,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: ProfileScreen.primaryColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 37,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 35,
                        backgroundColor: const Color(0xFFF5DCE3),
                        backgroundImage:
                            avatarBase64 != null && avatarBase64.isNotEmpty
                            ? MemoryImage(base64Decode(avatarBase64))
                            : null,
                        child: avatarBase64 == null || avatarBase64.isEmpty
                            ? const Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.grey,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (profileProvider.isLoading)
                            const Text(
                              '',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            )
                          else
                            Text(
                              profile?.name ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          const SizedBox(height: 5),
                          Text(
                            profileProvider.isLoading
                                ? ''
                                : profile?.email ??
                                      profileProvider.errorMessage ??
                                      'No email available',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const HugeIcon(
                      color: Colors.white,
                      size: 30,
                      icon: HugeIconsStrokeRounded.chevronRight,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Configuration options
            Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade900 : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: isDark
                    ? Border.all(color: Colors.grey.shade700)
                    : Border.all(color: const Color(0xFFEEEEEE)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Settings
                  _buildOption(
                    icon: HugeIconsStrokeRounded.settings02,
                    title: 'Settings',
                    subtitle: 'App preferences and sync options',
                    onTap: () => _onSettingsTap(context),
                  ),

                  const Divider(height: 1, color: Color(0xFFEEEEEE)),

                  // Static Switch Accounts option
                  _buildOption(
                    icon: HugeIconsStrokeRounded.userSwitch,
                    title: 'Switch Accounts',
                    subtitle: 'Add multiple accounts to switch quickly',
                    trailing: const Icon(
                      Icons.keyboard_arrow_down,
                      size: 29,
                      color: Color(0xFF555555),
                    ),
                  ),

                  const Divider(height: 1, color: Color(0xFFEEEEEE)),

                  // Logout
                  _buildOption(
                    icon: HugeIconsStrokeRounded.logout01,
                    title: 'Logout',
                    subtitle: 'Sign out from this device',
                    iconColor: Colors.red,
                    titleColor: Colors.red,
                    onTap: () => _showLogoutDialog(context),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOption({
    required List<List<dynamic>> icon,
    required String title,
    required String subtitle,
    Color iconColor = ProfileScreen.secondaryText,
    Color? titleColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            SizedBox(
              width: 48,
              child: HugeIcon(icon: icon, size: 28, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 15,
                      color: ProfileScreen.secondaryText,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            trailing ??
                const Icon(
                  Icons.chevron_right,
                  size: 28,
                  color: Color(0xFF555555),
                ),
          ],
        ),
      ),
    );
  }
}
