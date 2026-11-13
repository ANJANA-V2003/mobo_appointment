import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class custom_card_2 extends StatelessWidget {
  const custom_card_2({
    super.key,
    required this.context,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    this.titleColor,
    this.trailing,
    this.onTap,
  });

  final BuildContext context;
  final List<List<dynamic>> icon;
  final String title;
  final String subtitle;
  final String description;
  final Color? titleColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                SizedBox(
                  width: 30,
                  child: HugeIcon(
                    icon: icon,
                    size: 22,
                    color: isDark ? Colors.grey : Colors.black,
                  ),
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          // color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      SizedBox(
                        width: 200,
                        child: Text(
                          description,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? Colors.grey.shade600
                                : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                if (trailing != null) ...[const SizedBox(width:15), ?trailing],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
