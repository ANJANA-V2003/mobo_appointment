import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:mobo_appointment_project/core/theme/app_theme.dart';
import 'package:mobo_appointment_project/features/profile/providers/profile_provider.dart';
import 'package:mobo_appointment_project/shared/widgets/form/app_text_field.dart';
import 'package:provider/provider.dart';

class ProfileDetailsScreen extends StatefulWidget {
  const ProfileDetailsScreen({super.key});

  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController webController = TextEditingController();
  final TextEditingController jobController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  bool _isEditing = false;
  bool _isProfileLoaded = false;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    final profile = context.watch<ProfileProvider>().profile;

    if (profile != null && !_isProfileLoaded) {
      nameController.text = profile.name;
      emailController.text = profile.email;
      phoneController.text = profile.phone;
      addressController.text = profile.address!;

      _isProfileLoaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;
    final image = profile?.avatarBase64;
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(), // change the route of popping
          icon: HugeIcon(icon: (HugeIconsStrokeRounded.chevronLeft)),
        ),
        title: const Text(
          'Profile Details',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w600,
            // color: Colors.black,
          ),
        ),
        actions: [
          if (_isEditing) ...[
            TextButton(
              onPressed: () {
                setState(() {
                  _isEditing = !_isEditing;
                });
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],

          TextButton(
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
            child: Text(
              _isEditing ? 'Save' : 'Edit',
              style: TextStyle(
                color: _isEditing ? Colors.black : Color(0xffb63755),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        physics: ScrollPhysics.alwaysScrollable(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 35),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 65,
                      backgroundColor: Colors.grey.shade300,
                      child: CircleAvatar(
                        radius: 61,
                        backgroundImage: image != null && image.isNotEmpty
                            ? MemoryImage(base64Decode(image))
                            : null,
                        child: image == null || image.isEmpty
                            ? const Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.grey,
                              )
                            : null,
                      ),
                    ),
                    if (_isEditing) ...[
                      Padding(
                        padding: const EdgeInsets.only(left: 90, top: 90),
                        child: Container(
                          height: 35,
                          width: 35,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 2),
                            color: Color(0xffb63755),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedCameraAdd02,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: 15),
              child: Center(child: subText(text: profile?.name ?? '')),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 40),
                  child: Text(
                    "Personal Information",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ),
                _buildProfileField(
                  label: "Full Name",
                  controller: nameController,
                  prefixIcon: HugeIcon(icon: HugeIcons.strokeRoundedIdCard),
                ),
                _buildProfileField(
                  label: "Email",
                  controller: emailController,
                  prefixIcon: HugeIcon(icon: HugeIcons.strokeRoundedMail01),
                ),
                _buildProfileField(
                  label: "Phone",
                  controller: phoneController,
                  prefixIcon: HugeIcon(icon: HugeIcons.strokeRoundedCall02),
                ),
                // Padding(
                //   padding: const EdgeInsets.only(left: 20, top: 10),
                //   child: subText(
                //     text: "Website",
                //     size: 16,
                //     color: Colors.grey.shade500,
                //   ),
                // ),
                // Padding(
                //   padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
                //   child: AppTextField(
                //     controller: webController,
                //     prefixIcon: Padding(
                //       padding: const EdgeInsets.only(left: 15, right: 10),
                //       child: HugeIcon(icon: HugeIcons.strokeRoundedWebDesign02),
                //     ),
                //   ),
                // ),
                _buildProfileField(
                  label: "Website",
                  controller: webController,
                  prefixIcon: HugeIcon(
                    icon: HugeIcons.strokeRoundedWebDesign02,
                  ),
                ),
                _buildProfileField(
                  label: "Job Title",
                  controller: jobController,
                  prefixIcon: HugeIcon(
                    icon: HugeIcons.strokeRoundedWorkHistory,
                  ),
                ),
                _buildProfileField(
                  label: "Company",
                  controller: jobController,
                  prefixIcon: HugeIcon(icon: HugeIcons.strokeRoundedBuilding05),
                ),
                // Padding(
                //   padding: const EdgeInsets.only(left: 20, top: 10),
                //   child: subText(
                //     text: "Related Company",
                //     size: 16,
                //     color: Colors.grey.shade500,
                //   ),
                // ),
                // Padding(
                //   padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
                //   child: AppTextField(
                //     controller: jobController,
                //     prefixIcon: Padding(
                //       padding: const EdgeInsets.only(left: 15, right: 10),
                //       child: HugeIcon(icon: HugeIcons.strokeRoundedBuilding01),
                //     ),
                //   ),
                // ),
                _buildProfileField(
                  label: "Related Company",
                  controller: jobController,
                  prefixIcon: HugeIcon(icon: HugeIcons.strokeRoundedBuilding01),
                ),
                _buildProfileField(
                  label: "Address",
                  controller: addressController,
                  prefixIcon: HugeIcon(icon: HugeIcons.strokeRoundedLocation05),
                ),
                // Padding(
                //   padding: const EdgeInsets.only(left: 20, top: 10),
                //   child: subText(
                //     text: "Address",
                //     size: 16,
                //     color: Colors.grey.shade500,
                //   ),
                // ),
                // Padding(
                //   padding: const EdgeInsets.only(
                //     left: 20,
                //     right: 20,
                //     top: 10,
                //     bottom: 50,
                //   ),
                //   child: AppTextField(
                //     controller: jobController,
                //     prefixIcon: Padding(
                //       padding: const EdgeInsets.only(left: 15, right: 10),
                //       child: HugeIcon(icon: HugeIcons.strokeRoundedLocation05),
                //     ),
                //   ),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField({
    required String label,
    required TextEditingController controller,
    required Widget prefixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          subText(text: label, size: 16, color: Colors.grey.shade500),
          const SizedBox(height: 10),

          if (_isEditing)
            AppTextField(
              controller: controller,
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 15, right: 10),
                child: prefixIcon,
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
              decoration: BoxDecoration(
                color: Color(0xffF2F4F6),

                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  prefixIcon,
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      controller.text.isEmpty ? '—' : controller.text,
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class subText extends StatelessWidget {
  final String text;
  final double? size;
  final Color? color;
  const subText({super.key, required this.text, this.color, this.size});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: size,
        color: color,
      ),
    );
  }
}
