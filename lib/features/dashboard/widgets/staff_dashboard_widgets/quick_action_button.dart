import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class QuickActionButton extends StatelessWidget {
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;
  final String text;
  final List<List> icon;
  final VoidCallback onTap;

  const QuickActionButton({
    super.key,
    required this.backgroundColor,
    required this.text,
    required this.icon,
    required this.onTap,
    this.textColor = Colors.white,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3)],
          color: backgroundColor,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HugeIcon(icon: icon, size: 18, strokeWidth: 2, color: iconColor),
            const SizedBox(width: 5),
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
