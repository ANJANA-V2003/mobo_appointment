import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mobo_appointment_project/core/theme/app_theme.dart';

class MyLoadCard extends StatelessWidget {
  final int? appointmentCount;
  final double? bookedHours;
  final double? availableHours;
  final VoidCallback? onTap;
  final bool isLoading;

  const MyLoadCard({
    super.key,
    this.appointmentCount,
    this.bookedHours,
    this.availableHours,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // simply hard coded data
    final count = appointmentCount ?? 0;
    final booked = bookedHours ?? 0;
    final available = availableHours ?? 0;

    final progress = available > 0 ? (booked / available).clamp(0.0, 1.0) : 0.0;

    final percentage = available > 0 ? (booked / available * 100).round() : 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        width: 250,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade900 : AppTheme.secondaryColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow:  [ BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.15)
                : Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),],
        ),
        child: isLoading
            ?  Center(
          child: LoadingAnimationWidget.staggeredDotsWave(
            color: Colors.grey.shade300,
            size: 60,
          ),
        )
            :  Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'My Load',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                HugeIcon(
                  icon: HugeIcons.strokeRoundedChartBarLine,
                  size: 20,
                  color: AppTheme.primaryColor,
                  strokeWidth: 2,
                ),
              ],
            ),

            const SizedBox(height: 6),

            // Appointment count
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
                    count == 1 ? 'Appointments today' : 'Appointments today',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 7,
                backgroundColor: isDark
                    ? Colors.grey.shade800
                    : Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryColor,
                ),
              ),
            ),

            const SizedBox(height: 6),

            // Booked hours and percentage
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${booked.toStringAsFixed(1)}h / '
                  '${available.toStringAsFixed(1)}h booked',
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  '$percentage%',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
