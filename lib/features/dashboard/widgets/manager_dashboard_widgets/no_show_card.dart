import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobo_appointment_project/core/theme/app_theme.dart';

class NoShowCard extends StatelessWidget {
  final double noShowRate;

  const NoShowCard({super.key, required this.noShowRate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 160,
      width: 250,
      padding: const EdgeInsets.only(top: 15, bottom: 15),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : AppTheme.secondaryColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'No-Show Rate',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                Tooltip(
                  message:
                      'No-Show Rate =\n'
                      '(No-Show Appointments / \n'
                      'Total Booked Appointments) * 100 %',
                  triggerMode: TooltipTriggerMode.tap,
                  waitDuration: const Duration(milliseconds: 300),

                  showDuration: const Duration(seconds: 3),

                  preferBelow: false,

                  decoration: BoxDecoration(
                    color: isDark ? Colors.white : Colors.black87,
                    borderRadius: BorderRadius.circular(8),
                  ),

                  textStyle: TextStyle(
                    color: isDark ? Colors.black : Colors.white,
                    fontSize: 12,
                    height: 1.5,
                  ),
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedInfo,
                    size: 18,
                    strokeWidth: 2,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Text(
              '${noShowRate.toStringAsFixed(1)}%',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: (noShowRate / 100).clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
              ),
            ),
          ),

          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Text('Filter no show rate', style: TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }
}
