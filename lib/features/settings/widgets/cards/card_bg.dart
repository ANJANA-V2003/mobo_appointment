import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class card_bg extends StatelessWidget {
  const card_bg({
    super.key,
    required this.isDark, required this.height,  this.child,
  });

  final bool isDark;
  final double height;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ?child
        ],
      ),
    );
  }
}