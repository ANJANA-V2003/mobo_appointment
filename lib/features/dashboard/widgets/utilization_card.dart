
import 'package:flutter/material.dart';
import 'package:mobo_appointment_project/core/theme/app_theme.dart';

class UtilizationCard extends StatelessWidget {
  final double utilizationRate;

  const UtilizationCard({
    super.key,
    required this.utilizationRate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:AppTheme.secondaryColor,
        borderRadius: BorderRadius.circular(12),
       boxShadow: [BoxShadow(blurRadius: 4,color: Colors.black12)]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Utilization Rate',
                style: theme.textTheme.titleSmall,
              ),
              Icon(
                Icons.info_outline,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
          const SizedBox(height: 16),

          Text(
            '${utilizationRate.toStringAsFixed(1)}%',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.normal,
              color:AppTheme.primaryText,
          ),
          ),

          const SizedBox(height: 12),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (utilizationRate / 100).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                colorScheme.primary,
              ),
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'Percentage of available appointment slots booked',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
