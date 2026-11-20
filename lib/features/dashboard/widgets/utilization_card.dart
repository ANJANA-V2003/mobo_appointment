import 'package:flutter/material.dart';
import 'package:mobo_appointment_project/core/theme/app_theme.dart';

class UtilizationCard extends StatelessWidget {
  final double utilizationRate;

  const UtilizationCard({super.key, required this.utilizationRate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 160,
      width: 250,
      padding: const EdgeInsets.only(top: 15),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : AppTheme.secondaryColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black12)],
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
                  'Utilization Rate',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                Icon(Icons.info_outline, size: 18),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Text(
              '${utilizationRate.toStringAsFixed(1)}%',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: (utilizationRate / 100).clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.orange.shade500,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Text('Tap to inspect slots', style: TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }
}
