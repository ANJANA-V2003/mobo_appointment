import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerBottomSheet extends StatelessWidget {
  const ImagePickerBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            type: MaterialType.transparency,
            child: ListTile(
              leading: const HugeIcon(icon: HugeIcons.strokeRoundedCamera02),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context, ImageSource.camera);
              },
            ),
          ),

          Divider(),
          Material(
            type: MaterialType.transparency,
            child: ListTile(
              leading: const HugeIcon(icon: HugeIcons.strokeRoundedImageCrop),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context, ImageSource.gallery);
              },
            ),
          ),
        ],
      ),
    );
  }
}
