import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class custom_card_5 extends StatelessWidget {
  const custom_card_5({
    super.key,
    required this.context,
    required this.icon,
    required this.subtitle,
    required this.description,
    this.trailing,
    this.onTap,
  });

  final BuildContext context;
  final List<List<dynamic>> icon;
  final String subtitle;
  final String description;
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
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 22,
                  child: HugeIcon(
                    icon: icon,
                    size: 24,
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
                          fontSize: 16,
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
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: isDark
                                ? Colors.grey.shade600
                                : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                if (trailing != null) ...[const SizedBox(width: 10), ?trailing],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
