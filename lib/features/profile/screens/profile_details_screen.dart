import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobo_appointment_project/core/routing/app_routes.dart';
import 'package:mobo_appointment_project/core/theme/app_theme.dart';
import 'package:mobo_appointment_project/features/login/provider/auth_provider.dart';
import 'package:mobo_appointment_project/features/profile/providers/profile_provider.dart';
import 'package:mobo_appointment_project/features/profile/widgets/image_picker_bottom_sheet_widget.dart';
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
  final TextEditingController companyController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  bool _isEditing = false;
  bool _isProfileLoaded = false;

  final ImagePicker _imagePicker = ImagePicker();

  Uint8List? _selectedImageBytes; // to display the image immediately
  String? _selectedImageBase64; // to hold the image data for the odoo

  Future<void> _pickProfileImage(ImageSource source) async {
    final pickedImage = await _imagePicker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 600,
    );

    if (pickedImage == null) return;
    final imageBytes = await pickedImage.readAsBytes();

    setState(() {
      _selectedImageBytes = imageBytes;
      _selectedImageBase64 = base64Encode(imageBytes);
    });
  }

  Future<void> _showImagePickerOptions() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const ImagePickerBottomSheet();
      },
    );

    if (source == null) return;

    _pickProfileImage(source);
  }

  Future<void> _saveProfile() async {
    final authProvider = context.read<AuthProvider>();

    final client = authProvider.client;
    final userId = authProvider.session?.userId;

    if (client == null || userId == null) {
      return;
    }
    final success = await context.read<ProfileProvider>().updateProfile(
      client: client,
      userId: userId,
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
      imageBase64: _selectedImageBase64,
    );

    if (!mounted) return;

    if (success) {
      //resetting all values
      setState(() {
        _isEditing = false;
        _selectedImageBytes = null;
        _selectedImageBase64 = null;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Profile updated successfully")));
    } else {
      final error = context.read<ProfileProvider>().errorMessage;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Unable to update profile')),
      );
    }
  }

  bool get _hasUnsavedChanges {
    final profile = context.read<ProfileProvider>().profile;

    if (profile == null) return false;

    return nameController.text != profile.name ||
        emailController.text != profile.email ||
        phoneController.text != profile.phone ||
        _selectedImageBase64 != null;
  }

  Future<void> _handleBackButton() async {
    if (_hasUnsavedChanges) {
      await _showWarningDialog(context);
    } else {
      context.pop();
    }
  }

  Future<void> _showWarningDialog(BuildContext context) async {
    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? Colors.grey[900] : Colors.white,
          icon: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Color(0xffF9eaed),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedAlert02,
                color: Color(0xffC03355),
              ),
            ),
          ),
          title: const Text('Discard Changes?',style: TextStyle(fontWeight: FontWeight.w600),),
          content: SizedBox(
            width: 100,
            child: Text(
              'You have unsaved changes that will be lost if you leave this page. '
              'Are you sure you want to discard these changes?',
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      side: BorderSide(color: AppTheme.primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: const Text(
                      'Keep Editing',
                      style: TextStyle(color: Color(0xffc03355),fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(dialogContext, true);
                      // context.goNamed(AppRoutes.profile);
                    },
                    child: const Text(
                      'Discard',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    if (shouldDiscard == true && context.mounted) {
      context.goNamed(AppRoutes.profile);
    }
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    final profile = context.watch<ProfileProvider>().profile;

    if (profile != null && !_isProfileLoaded) {
      nameController.text = profile.name;
      emailController.text = profile.email;
      phoneController.text = profile.phone;
      addressController.text = profile.address;
      webController.text = profile.website;
      companyController.text = profile.company;

      _isProfileLoaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;
    final image = profile?.avatarBase64;

    final ImageProvider? profileImage = _selectedImageBytes != null
        ? MemoryImage(_selectedImageBytes!)
        : image != null && image.isNotEmpty
        ? MemoryImage(base64Decode(image))
        : null;

    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        elevation: 0,
        leading: IconButton(
          onPressed: () => _handleBackButton(),
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
          if (_isEditing)
            TextButton(
              style: ButtonStyle(
                overlayColor: WidgetStateColor.transparent,
                splashFactory: NoSplash.splashFactory,
              ),
              onPressed: context.watch<ProfileProvider>().isSaving
                  ? null
                  : () {
                      setState(() {
                        _isEditing = false;
                        _selectedImageBytes = null;
                        _selectedImageBase64 = null;

                        // Restore original fetched values
                        final profile = context.read<ProfileProvider>().profile;

                        if (profile != null) {
                          nameController.text = profile.name;
                          emailController.text = profile.email;
                          phoneController.text = profile.phone;
                        }
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

          TextButton(
            style: ButtonStyle(
              overlayColor: WidgetStateColor.transparent,
              splashFactory: NoSplash.splashFactory,
            ),
            onPressed: context.watch<ProfileProvider>().isSaving
                ? null
                : () {
                    if (_isEditing) {
                      _saveProfile();
                    } else {
                      setState(() {
                        _isEditing = true;
                      });
                    }
                  },
            child: Text(
              context.watch<ProfileProvider>().isSaving
                  ? 'Saving...'
                  : _isEditing
                  ? 'Save'
                  : 'Edit',
              style: TextStyle(
                color: _isEditing ? Colors.black : const Color(0xffb63755),
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
                        backgroundImage: profileImage,
                        child: profileImage == null
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
                        child: InkWell(
                          onTap: _showImagePickerOptions,
                          child: Container(
                            height: 35,
                            width: 35,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 2),
                              color: Color(0xffb63755),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: HugeIcon(
                                icon: HugeIcons.strokeRoundedCameraAdd02,
                                color: Colors.white,
                              ),
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
                _buildProfileField(
                  label: "Website",
                  hint: "Enter Website",
                  controller: webController,
                  prefixIcon: HugeIcon(
                    icon: HugeIcons.strokeRoundedWebDesign02,
                  ),
                ),
                _buildProfileField(
                  hint: "Enter Job Title",
                  label: "Job Title",
                  controller: jobController,
                  prefixIcon: HugeIcon(
                    icon: HugeIcons.strokeRoundedWorkHistory,
                  ),
                ),
                _buildProfileField(
                  label: "Company",
                  controller: companyController,
                  prefixIcon: HugeIcon(icon: HugeIcons.strokeRoundedBuilding05),
                ),
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
              ],
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField({
    String? hint,
    required String label,
    required TextEditingController controller,
    required Widget prefixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          subText(text: label, size: 16, color: Colors.grey.shade500),
          const SizedBox(height: 10),

          if (_isEditing)
            AppTextField(
              hintText: hint,
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
                      controller.text.isEmpty ? 'Not set' : controller.text,
                      style: controller.text.isEmpty
                          ? TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: Colors.grey.shade400,
                              fontStyle: FontStyle.italic,
                            )
                          : TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
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
