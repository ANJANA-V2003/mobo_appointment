import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobo_appointment_project/core/theme/app_theme.dart';

class UpNextCard extends StatelessWidget {
  final int? clientCount;
  final String? nextClientName;
  final String? nextAppointmentTime;
  final String? appointmentEndTime;
  final VoidCallback? onTap;
  const UpNextCard({
    super.key,
    this.clientCount,
    this.nextClientName,
    this.nextAppointmentTime,
    this.onTap,
    this.appointmentEndTime,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                    'Up Next',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  Container(
                    height: 20,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Color(0xFFF6CA8A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: nextClientName == null
                          ? null
                          : Text(
                              '${nextAppointmentTime}',
                              style: TextStyle(
                                color: Color(0xFFED9126),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Text(
                '${nextClientName ?? 'No Client'}',
                // 'Joel Will',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: nextClientName == null
                  ? Text(
                      "No bookings left",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade500,
                      ),
                    )
                  : Text(
                      // "Appointment: 11:00 AM - 1:00 PM",
                      'Appointment:${nextAppointmentTime} - ${appointmentEndTime}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade500,
                      ),
                    ),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: Divider(),
            ),
            Spacer(),

            Padding(
              padding: const EdgeInsets.only(right: 15, left: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Text(
                  //   'Starts in ${minutesUntilNext} m',
                  //   // 'Starts in 15 m',
                  //   style: TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
                  // ),
                  Row(
                    children: [
                      Text(
                        'Details',
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
          ],
        ),
      ),
    );
  }
}
