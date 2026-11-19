
import 'package:flutter/material.dart';
import 'package:mobo_appointment_project/core/theme/app_theme.dart';

class NoShowCard extends StatelessWidget {
  final double noShowRate;

  const NoShowCard({
    super.key,
    required this.noShowRate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.secondaryColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12,blurRadius: 4)]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'No-Show Rate',
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
            '${noShowRate.toStringAsFixed(1)}%',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.normal,
              color: AppTheme.primaryText,
            ),
          ),

          const SizedBox(height: 12),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (noShowRate / 100).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor:
              colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                colorScheme.error,
              ),
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'Percentage of appointments missed by customers',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
