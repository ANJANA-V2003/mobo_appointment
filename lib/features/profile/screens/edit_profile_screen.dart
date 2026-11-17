import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () => context. pop(), // change the route of popping
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
    );
  }
}
