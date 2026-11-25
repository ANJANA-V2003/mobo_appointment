import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobo_appointment_project/core/theme/app_theme.dart';

class ArrivingSoonCard extends StatelessWidget {
  final int? clientCount;
  final String? nextClientName;
  final VoidCallback? onTap;
  final int? minutesUntilNext;
  const ArrivingSoonCard({
    super.key,
    this.clientCount,
    this.nextClientName,
    this.onTap,
    this.minutesUntilNext,
  });

  @override
  Widget build(BuildContext context) {
    final count = clientCount ?? 0;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        width: 250,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade900 : AppTheme.secondaryColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Arriving Soon',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                if (minutesUntilNext != null)
                Container(
                  height: 20,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Color(0xffafcfbb),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      // "15 m"

                      '${minutesUntilNext ?? 0} m',
                      style: TextStyle(
                        color: Color(0xff326c56),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$count',
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    count == 1 ? 'Expected clients' : 'Expected clients',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 5),

            Text(
              // "Next : Joel Will",
              'Next : ${nextClientName ?? 'No upcoming client'}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500,
              ),
            ),

            Divider(),

            Spacer(),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Click to view',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    color: AppTheme.primaryColor,
                  ),
                ),
                SizedBox(width: 4),
                HugeIcon(
                  icon: HugeIcons.strokeRoundedChevronRight,
                  size: 15,
                  color: AppTheme.primaryColor,
                  strokeWidth: 2,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
