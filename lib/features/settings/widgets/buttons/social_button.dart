import 'package:flutter/cupertino.dart';

class social_button extends StatelessWidget {
  const social_button({
    super.key,
    required this.context,
    required this.imagePath,
    required this.label,
    required this.onPressed,
  });

  final BuildContext context;
  final String imagePath;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            width: 46,
            height: 46,
            padding: const EdgeInsets.all(12),
            child: Image.asset(
              imagePath,
              width: 24,
              height: 24,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }
}
