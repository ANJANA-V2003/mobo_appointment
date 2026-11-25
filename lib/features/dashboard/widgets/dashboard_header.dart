import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobo_appointment_project/core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:mobo_appointment_project/features/profile/providers/profile_provider.dart';

class DashboardHeader extends StatelessWidget {
  final String location;
  final VoidCallback? onLocationTap;
  final VoidCallback? onProfileTap;
  final String description;

  const DashboardHeader({
    super.key,
    this.location = 'San Francisco',
    this.onLocationTap,
    this.onProfileTap,
    required this.description,
  });

  static const Color primaryColor = Color(0xFFC03355);

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning,';
    } else if (hour < 17) {
      return 'Good Afternoon,';
    } else if (hour < 21) {
      return 'Good Evening,';
    } else {
      return 'Good Night,';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get profile details from ProfileProvider
    final profileProvider = context.watch<ProfileProvider>();
    final profile = profileProvider.profile;

    // Get user name
    final userName = profile?.name ?? 'User';

    // Convert Base64 image into ImageProvider
    ImageProvider? profileImage;

    if (profile?.avatarBase64 != null && profile!.avatarBase64!.isNotEmpty) {
      try {
        profileImage = MemoryImage(base64Decode(profile.avatarBase64!));
      } catch (e) {
        debugPrint('Profile image decoding failed: $e');
      }
    }

    return Column(
      children: [
        // Welcome Card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: _buildWelcomeCard(userName, profileImage),
        ),
      ],
    );
  }

  Widget _buildWelcomeCard(String userName, ImageProvider? profileImage) {
    return Container(
      height: 135,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Greeting
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text(
                 _getGreeting(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  '$userName!',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  description,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.75),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // User Profile Image
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 33,
              backgroundColor: primaryColor,
              child: CircleAvatar(
                radius: 25,
                backgroundColor: const Color(0xFFE8F1FF),
                backgroundImage: profileImage,
                child: profileImage == null
                    ? const Icon(Icons.person, color: primaryColor, size: 28)
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
