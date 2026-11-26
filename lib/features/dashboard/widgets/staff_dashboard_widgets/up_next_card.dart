import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mobo_appointment_project/core/theme/app_theme.dart';

class UpNextCard extends StatelessWidget {
  final int? clientCount;
  final String? nextClientName;
  final String? nextAppointmentTime;
  final String? appointmentEndTime;
  final VoidCallback? onTap;
  final bool isLoading;
  const UpNextCard({
    super.key,
    this.clientCount,
    this.nextClientName,
    this.nextAppointmentTime,
    this.onTap,
    this.appointmentEndTime,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        width: 250,
        padding: const EdgeInsets.only(top: 15, bottom: 15),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade900 : AppTheme.secondaryColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.15)
                  : Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: isLoading
            ? Center(
                child: LoadingAnimationWidget.staggeredDotsWave(
                  color: Colors.grey.shade300,
                  size: 60,
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Up Next',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
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

                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Text(
                      nextClientName ?? 'No Client',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: nextClientName == null
                        ? Text(
                            'No bookings left',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade500,
                            ),
                          )
                        : Text(
                            'Appointment: $nextAppointmentTime - $appointmentEndTime',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade500,
                            ),
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}
